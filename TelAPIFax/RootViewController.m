//
//  RootViewController.m
//  IOSBoilerplate
//
//  Copyright (c) 2011 Alberto Gimeno Brieba
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "RootViewController.h"
#import "HTTPHUDExample.h"
#import "AsyncImageExample.h"
#import "AsyncCellImagesExample.h"
#import "VariableHeightExample.h"
#import "DirectionsExample.h"
#import "AutocompleteLocationExample.h"
#import "PullDownExample.h"
#import "SwipeableTableViewExample.h"
#import "BrowserSampleViewController.h"

@implementation RootViewController

@synthesize phoneNumber, preview;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"TelAPI Fax";
    
    [AmazonLogger verboseLogging];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}







- (IBAction)takePicture:(id)sender {
    [self.phoneNumber resignFirstResponder];
    NSLog(@"Take picture");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        NSLog(@"Camera supported");
        
        UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        cameraUI.allowsEditing = YES;
        cameraUI.delegate = self;
        [self presentViewController: cameraUI animated: YES completion:nil];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Device does not have camera"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


- (IBAction)selectFile:(id)sender {
    [self.phoneNumber resignFirstResponder];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController: picker animated: YES completion:nil];
    
}



- (IBAction)sendFax:(id)sender {
    if([self.phoneNumber.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Blank Phone Number"
                                    message:@"Please enter a destination number before sending fax"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    [SVProgressHUD showInView:self.view status:@"Uploading Fax..." networkIndicator:YES];
    
    // Run outside of UI thread with Grand Central Dispatch
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        NSString *uuidStr = CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        
        // Resize Image
        UIGraphicsBeginImageContext(CGSizeMake(640, 480));
        [self.preview.image drawInRect:CGRectMake(0,0,640,480)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageData = UIImagePNGRepresentation(newImage);
        
        // Upload to S3
        AmazonS3Client *s3 = [[[AmazonS3Client alloc] initWithAccessKey:S3_KEY_ID withSecretKey:S3_KEY_SECRET] autorelease];
        [s3 createBucket:[[[S3CreateBucketRequest alloc] initWithName:S3_BUCKET] autorelease]];
        
        S3PutObjectRequest *por = [[[S3PutObjectRequest alloc] initWithKey:uuidStr inBucket:S3_BUCKET] autorelease];
        por.contentType = @"image/png";
        por.data = imageData;
        [s3 putObject:por];
        
        S3ResponseHeaderOverrides *override = [[[S3ResponseHeaderOverrides alloc] init] autorelease];
        override.contentType = @"image/png";
        
        S3GetPreSignedURLRequest *gpsur = [[[S3GetPreSignedURLRequest alloc] init] autorelease];
        gpsur.key     = uuidStr;
        gpsur.bucket  = S3_BUCKET;
        gpsur.expires = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600];  // Added an hour's worth of seconds to the current time.
        gpsur.responseHeaderOverrides = override;
        
        NSURL *imageUrl = [s3 getPreSignedURL:gpsur];
        
        NSLog(@"Uploaded url: %@", imageUrl);
        
        NSDictionary *postParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"9492660933", @"From",
                                    self.phoneNumber.text, @"To",
                                    [imageUrl absoluteString], @"Url",
                                    nil];
        
//        NSLog(@"Post Params: %@", postParams);
        
        [SVProgressHUD showInView:self.view status:@"Submitting Fax..." networkIndicator:YES];
        
        [[TelAPIClient sharedClient] postPath:@"/Faxes.json" parameters:postParams success:^(id JSON) {
            
            NSLog(@"TelAPI Response: %@", JSON);
            
            NSString *status = [JSON objectForKey:@"status"];
            
            if([status isEqualToString:@"queued"]) {
                [self performSelector:@selector(showFaxList:) withObject:nil afterDelay:2];
                [SVProgressHUD dismissWithSuccess:@"Fax queued successfully!" afterDelay:3];
            } else {
                [SVProgressHUD dismissWithError:@"Error queueing fax" afterDelay:5];
            }
        } failure:^(NSHTTPURLResponse *operation, NSError *error) {
            [SVProgressHUD dismiss];
            
            NSLog(@"Error submitting fax to TelAPI: %@", error);
            [[[UIAlertView alloc] initWithTitle:@"Error Sending Fax"
                                        message:@"Some error from TelAPI"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }];
    });
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
    NSLog(@"image picker: %@", info);
    
    if([info objectForKey:UIImagePickerControllerEditedImage] != nil) {
        self.preview.image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else {
        self.preview.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
}



- (IBAction)showFaxList:(id)sender {
    FaxListViewController *listView = [[[FaxListViewController alloc] init] autorelease];
    [listView reloadTableViewDataSource];
    [self.navigationController pushViewController:listView animated:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    [phoneNumber release];
    [preview release];
    [super dealloc];
}

@end
