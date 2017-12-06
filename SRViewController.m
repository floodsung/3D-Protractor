//
//  SRViewController.m
//  3D Protractor
//
//  Created by Rotek on 12-12-31.
//  Copyright (c) 2012年 Rotek. All rights reserved.
//

#import "SRViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GADBannerView.h"
#import "GADRequest.h"
#import "AGLKContext.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModelManager.h"
#import "UtilityTextureInfo.h"
#import "SRMath.h"
#import "SRAppID.h"
#import "SRTextIndicator.h"
#import "SRCameraEngine.h"
#import "SRSlopeMeasureEngine.h"
#import "SRDihedralAngleMeasureEngine.h"
#import "SRLinePlainAngleMeasureEngine.h"

#ifdef LITE_VERSION
#import "SRInAppPurchaseViewController.h"
#endif


#define  AD_UNIT_ID  @"a150d694ff67999"


typedef enum {
    AngleMeasure = 0,
    CameraAngleMeasure,
    SlopeMeasure,
    DihedralAngleMeasure,
    LinePlainAngleMeasure,
}MeasureMode;

typedef enum {
    modeHide,
    modeShow,
}ModeStatus;

@interface SRViewController ()<
        SRSlopeMeasureEngineProtocol,SRDihedralAngleMeasureEngineProtocol,SRLinePlainAngleMeasureEngineProtocol
    >
{
    int _clickCount;  // to record the measure button click so as to draw suitable view
    MeasureMode _measureMode;
    ModeStatus _modeStatus;
    BOOL _textIndicatorIsOff;
}
@property (nonatomic,strong) UILabel *displayLabel;
@property (nonatomic,strong) UILabel *radDisplayLabel;
@property (nonatomic,strong) GLKBaseEffect *baseEffect;
@property (nonatomic,strong) UtilityModelManager *modelManager;
@property (nonatomic,strong) UtilityModel *axis;
@property (nonatomic,strong) UtilityModel *degree;
@property (nonatomic,strong) UtilityModel *circle;
@property (nonatomic,strong) UtilityModel *plain;
@property (nonatomic,strong) UtilityModel *chip;
@property (nonatomic,strong) UtilityModel *target;
@property (nonatomic,strong) SRAngleMeasureEngine *angleMeasureEngine;
@property (nonatomic,strong) UIButton *settingButton;
@property (nonatomic,strong) UIButton *modeButton;
@property (nonatomic,strong) SRTextIndicator *textIndicator;
@property (nonatomic,strong) UIView *grayView;
@property (nonatomic,strong) UIButton *angleMeasureButton;
@property (nonatomic,strong) UIButton *slopeMeasureButton;
@property (nonatomic,strong) UIButton *dihedralMeasureButton;
@property (nonatomic,strong) UIButton *plainLineMeasureButton;

@property (nonatomic,strong) SRCameraAngleMeasureEngine *cameraAngleMeasureEngine;
@property (nonatomic,strong) UIButton *cameraAngleMeasureButton;

@property (nonatomic,readwrite) CFURLRef soundFileURLRef;
@property (nonatomic,readonly) SystemSoundID soundFileObject;

@property (nonatomic,strong) SRSlopeMeasureEngine *slopeMeasureEngine;
@property (nonatomic,strong) SRDihedralAngleMeasureEngine *dihedralAngleMeasureEngine;
@property (nonatomic,strong) SRLinePlainAngleMeasureEngine *linePlainAngleMeasureEngine;

#ifdef LITE_VERSION
    @property (nonatomic,strong) GADBannerView *adBanner;
    @property (nonatomic,strong) ADBannerView *appleAdBanner;
#endif

@end

@implementation SRViewController
@synthesize displayLabel = _displayLabel;
@synthesize radDisplayLabel = _radDisplayLabel;
@synthesize motionManager = _motionManager;
@synthesize baseEffect = _baseEffect;
@synthesize modelManager = _modelManager;
@synthesize axis = _axis;
@synthesize circle = _circle;
@synthesize degree = _degree;
@synthesize plain = _plain;
@synthesize chip = _chip;
@synthesize target = _target;
@synthesize angleMeasureEngine = _angleMeasureEngine;
@synthesize settingButton = _settingButton;
@synthesize modeButton = _modeButton;
@synthesize textIndicator = _textIndicator;
@synthesize grayView = _grayView;
@synthesize angleMeasureButton = _angleMeasureButton;
@synthesize slopeMeasureButton = _slopeMeasureButton;
@synthesize dihedralMeasureButton = _dihedralMeasureButton;
@synthesize plainLineMeasureButton = _plainLineMeasureButton;

@synthesize cameraAngleMeasureEngine = _cameraAngleMeasureEngine;
@synthesize cameraAngleMeasureButton = _cameraAngleMeasureButton;
@synthesize viewControllerDelegate = _viewControllerDelegate;

@synthesize soundFileURLRef = _soundFileURLRef;
@synthesize soundFileObject = _soundFileObject;

@synthesize slopeMeasureEngine = _slopeMeasureEngine;
@synthesize dihedralAngleMeasureEngine = _dihedralAngleMeasureEngine;
@synthesize linePlainAngleMeasureEngine = _linePlainAngleMeasureEngine;
#ifdef LITE_VERSION
    @synthesize adBanner = _adBanner;
    @synthesize appleAdBanner = _appleAdBanner;
#endif

#pragma mark - Viewcontroller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Configure tap sound
    // Create the URL for the source audio file
    NSURL *tapSound = [[NSBundle mainBundle] URLForResource:@"button" withExtension:@"amr"];
    // Store the URL as a CFURLRef instance
    self.soundFileURLRef = (__bridge CFURLRef)tapSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(self.soundFileURLRef, &_soundFileObject);
    
    // Configure Admob banner

#ifdef LITE_VERSION
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"RemoveAd"]) {
        [self setupAdBanner];
    }
#endif
    
    [self checkUpdate];
    
    // Configure OpenGL ES 2.0 View
    [self setupOpenGL];
    
    // Setup measurement unit
    [self setupMeasurementUnit];

    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *everRated = [defaults objectForKey:@"Ever Rated"];
    NSNumber *indicatorCounter = [defaults objectForKey:@"Indicator counter"];
    NSLog(@"counter = %@,ever rated = %@",indicatorCounter,everRated);
    if (everRated == nil) {
        everRated = [NSNumber numberWithBool:NO];
        [defaults setObject:everRated forKey:@"Ever Rated"];
    }
    if (indicatorCounter == nil) {
        indicatorCounter = [NSNumber numberWithInt:1];
        [defaults setObject:indicatorCounter forKey:@"Indicator counter"];
    }
    if (![everRated boolValue] ) {
        if ([indicatorCounter intValue] % 5 == 3) {
            [self showRateAlert];
        }
    }
    int counter = [indicatorCounter intValue];
    counter++;
    indicatorCounter = [NSNumber numberWithInt:counter];
    [defaults setObject:indicatorCounter forKey:@"Indicator counter"];
    [defaults synchronize];
    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [AGLKContext setCurrentContext:nil];
    
    self.displayLabel = nil;
    self.radDisplayLabel = nil;
    self.motionManager = nil;
    self.modelManager = nil;
    self.baseEffect = nil;
    self.axis = nil;
    self.circle = nil;
    self.degree = nil;
    self.plain = nil;
    self.chip = nil;
    self.target = nil;
    
    self.angleMeasureEngine = nil;
    self.textIndicator = nil;
    self.modeButton = nil;
    self.settingButton = nil;
    
    self.grayView = nil;
    self.angleMeasureButton = nil;
    self.slopeMeasureButton = nil;
    self.dihedralMeasureButton = nil;
    self.plainLineMeasureButton = nil;
    
    self.cameraAngleMeasureEngine = nil;
    self.cameraAngleMeasureButton = nil;
    self.viewControllerDelegate = nil;
    
    self.slopeMeasureEngine = nil;
    self.dihedralAngleMeasureEngine = nil;
    self.linePlainAngleMeasureEngine = nil;
    
#ifdef LITE_VERSION
    self.adBanner.delegate = nil;
    self.adBanner = nil;
    self.appleAdBanner = nil;
    self.appleAdBanner.delegate = nil;
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *value = [defaults objectForKey:@"Text indicator is off"];
    _textIndicatorIsOff = [value boolValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)checkUpdate
{
    NSLog(@"check update...");
    dispatch_queue_t requestVersion = dispatch_queue_create("requestVersion", NULL);
    dispatch_async(requestVersion, ^{
        NSString *requestString = [[NSString alloc] init];
#ifdef LITE_VERSION
        requestString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@",APP_ID_LITE_VERSION];
#else
        requestString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@",APP_ID_FULL_VERSION];
#endif
        
        requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *request = [NSURL URLWithString:requestString];
        
        NSData *jsonData = [[NSString stringWithContentsOfURL:request encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        
        NSDictionary *json = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
        
        if (error) {
            NSLog(@"error is%@",[error localizedDescription]);
        }
        
        if (json) {

            NSString *serverVersion = [[json valueForKeyPath:@"results.version"] objectAtIndex:0];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *currentVersion = [defaults objectForKey:@"Version"];
            NSLog(@"Server Version: %@\nCurrentVersion:%@",serverVersion,currentVersion);
            
            if (![serverVersion isEqualToString:currentVersion]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showUpdateAlert];
                });
                
            }
            
        }

    });
    NSLog(@"end request");
    dispatch_release(requestVersion);
    
}


- (void)showUpdateAlert
{
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Update", @"Update") message:NSLocalizedString(@"The app has released new version,you can update now!", @"The app has released new version,you can update now!") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel") otherButtonTitles:NSLocalizedString(@"Update", @"Update"), nil];
    [updateAlert show];
}
 


- (void)showRateAlert
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *indicatorCounter = [defaults objectForKey:@"Indicator counter"];

    if (indicatorCounter == nil) {
        indicatorCounter = [NSNumber numberWithInt:1];
        [defaults setObject:indicatorCounter forKey:@"Indicator counter"];
    }
    
    int counter = [indicatorCounter intValue];
    counter++;
    indicatorCounter = [NSNumber numberWithInt:counter];
    [defaults setObject:indicatorCounter forKey:@"Indicator counter"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rate", @"rate") message:NSLocalizedString(@"Dear friends:Rate this app right now! Your five star rating is our best inspiration to make this app better!", @"Dear friends:Rate this app right now! Your five star rating is our best inspiration to make this app better!") delegate:self cancelButtonTitle:NSLocalizedString(@"Rate later", @"rate later") otherButtonTitles:NSLocalizedString(@"Rate", @"rate"), nil];
    [alertView show];
}

#pragma mark - Measurement Unit configuration

/*
- (void)setupLiteVersion
{
    _measureMode = AngleMeasure;
    _modeStatus = modeHide;
    _clickCount = 0;
    // Add view
    [self addDisplay];
    [self addBasicButtons];
    [self addPlusButtons];
    
    // Initial text indicator
    self.textIndicator = [[SRTextIndicator alloc] initWithView:self.view];

    // Initial measure engine
    self.angleMeasureEngine = [[SRAngleMeasureEngine alloc] init];
    self.angleMeasureEngine.delegate = self;
    self.cameraAngleMeasureEngine = [[SRCameraAngleMeasureEngine alloc] init];
    self.cameraAngleMeasureEngine.delegate = self;
    
}
 */


- (void)setupMeasurementUnit
{
    // Initial mode
    _measureMode = AngleMeasure;
    _modeStatus = modeHide;
    _clickCount = 0;
    
    
    // Add view
    [self addDisplay];
    [self addBasicButtons];
    [self addPlusButtons];
    
    // Initial text indicator
    self.textIndicator = [[SRTextIndicator alloc] initWithView:self.view];

    
    // Initial measure engine
    self.angleMeasureEngine = [[SRAngleMeasureEngine alloc] init];
    self.angleMeasureEngine.delegate = self;
    self.slopeMeasureEngine = [[SRSlopeMeasureEngine alloc] init];
    self.slopeMeasureEngine.delegate = self;
    self.dihedralAngleMeasureEngine = [[SRDihedralAngleMeasureEngine alloc] init];
    self.dihedralAngleMeasureEngine.delegate = self;
    self.linePlainAngleMeasureEngine = [[SRLinePlainAngleMeasureEngine alloc] init];
    self.linePlainAngleMeasureEngine.delegate = self;
    
    self.cameraAngleMeasureEngine = [[SRCameraAngleMeasureEngine alloc] init];
    self.cameraAngleMeasureEngine.delegate = self;
    
}

- (void)addDisplay
{
    // Add Display view
    UIView *displayView = [[UIView alloc] init];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        displayView.frame = CGRectMake(20, 30, 110, 40);
    } else {
        displayView.frame = CGRectMake(50, 70, 150, 60);
    }
    [self.view addSubview:displayView];
    
    // Set up display label
    self.displayLabel = [[UILabel alloc] init];
    self.radDisplayLabel = [[UILabel alloc] init];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.displayLabel.frame = CGRectMake(0, 0, 110, 40);
        self.displayLabel.font = [UIFont boldSystemFontOfSize:35];
        self.radDisplayLabel.frame = CGRectMake(0, 0, 110, 40);
        self.radDisplayLabel.font = [UIFont boldSystemFontOfSize:35];
    } else {
        self.displayLabel.frame = CGRectMake(0, 0, 150, 60);
        self.displayLabel.font = [UIFont boldSystemFontOfSize:45];
        self.radDisplayLabel.frame = CGRectMake(0, 0, 150, 60);
        self.radDisplayLabel.font = [UIFont boldSystemFontOfSize:45];
    }
    self.displayLabel.text = @"0.0°";
    self.displayLabel.textColor = [UIColor whiteColor];
    self.displayLabel.textAlignment = UITextAlignmentRight;
    //[UIFont fontWithName:@"DBLCDTempBlack" size:35];
    self.displayLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.displayLabel.layer.shadowOffset = CGSizeMake(0, 1);
    self.displayLabel.layer.shadowRadius = 3;
    self.displayLabel.layer.masksToBounds = NO;
    self.displayLabel.layer.shadowOpacity = 1;
    self.displayLabel.backgroundColor = [UIColor clearColor];
    self.displayLabel.userInteractionEnabled = YES;
    [displayView addSubview:self.displayLabel];
    
    self.radDisplayLabel.text = @"0.00r";
    self.radDisplayLabel.textColor = [UIColor whiteColor];
    self.radDisplayLabel.textAlignment = UITextAlignmentRight;
    //[UIFont fontWithName:@"DBLCDTempBlack" size:35];
    self.radDisplayLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.radDisplayLabel.layer.shadowOffset = CGSizeMake(0, 1);
    self.radDisplayLabel.layer.shadowRadius = 3;
    self.radDisplayLabel.layer.masksToBounds = NO;
    self.radDisplayLabel.layer.shadowOpacity = 1;
    self.radDisplayLabel.backgroundColor = [UIColor clearColor];
    self.radDisplayLabel.userInteractionEnabled = YES;
    
    // Set gesture
    UITapGestureRecognizer *tapDisplayLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDisplayLabel:)];
    [self.displayLabel addGestureRecognizer:tapDisplayLabel];
    
    UITapGestureRecognizer *tapRadDisplayLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRadDisplayLabel:)];
    [self.radDisplayLabel addGestureRecognizer:tapRadDisplayLabel];
    
}

- (void)tapDisplayLabel:(id)gesture
{
    [UIView transitionFromView:self.displayLabel toView:self.radDisplayLabel duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:nil];
}

- (void)tapRadDisplayLabel:(id)gesture
{
    [UIView transitionFromView:self.radDisplayLabel toView:self.displayLabel duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:nil];
}

- (void)addBasicButtons
{
    // Add measure button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    /* Original layout
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        button.frame = CGRectMake(self.view.frame.size.width - 90, 10, 80, 80);
    } else {
        button.frame = CGRectMake(self.view.frame.size.width - 130, 30,100, 100);
    }
     */
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        button.frame = CGRectMake(self.view.frame.size.width - 90, self.view.frame.size.height - 120, 80, 80);
    } else {
        button.frame = CGRectMake(self.view.frame.size.width - 130, self.view.frame.size.height - 110,100, 100);
    }
    
    [button setImage:[UIImage imageNamed:@"MeasureButton"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"MeasureButtonD"] forState:UIControlStateHighlighted];
    [self.view addSubview:button];

    [button addTarget:self action:@selector(measure:) forControlEvents:UIControlEventTouchUpInside];
    
    // Add setting button
    self.settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    /*
#ifdef LITE_VERSION
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.settingButton.frame = CGRectMake(10, self.view.frame.size.height - 60, 50, 50);
    } else {
        self.settingButton.frame = CGRectMake(30, self.view.frame.size.height - 90, 60, 60);
    }
#else
     */

    /* Original layout
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
      self.settingButton.frame = CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - 60, 50, 50);
    } else {
      self.settingButton.frame = CGRectMake(self.view.frame.size.width - 110, self.view.frame.size.height - 110, 80, 80);
    }
     */
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.settingButton.frame = CGRectMake(self.view.frame.size.width - 60, 10, 50, 50);
    } else {
        self.settingButton.frame = CGRectMake(self.view.frame.size.width - 110, 30, 80, 80);
    }
    
    [self.settingButton setImage:[UIImage imageNamed:@"SettingButton"] forState:UIControlStateNormal];
    [self.settingButton setImage:[UIImage imageNamed:@"SettingButtonD"] forState:UIControlStateHighlighted];
    [self.settingButton addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingButton];
    
    /*
    // Add Re-calibrate button
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        resetButton.frame = CGRectMake(self.view.frame.size.width - 60, 75, 50, 50);
    } else {
        resetButton.frame = CGRectMake(self.view.frame.size.width - 110, 130,80, 80);
    }
    [resetButton setImage:[UIImage imageNamed:@"ResetButton"] forState:UIControlStateNormal];
    [resetButton setImage:[UIImage imageNamed:@"ResetButtonD"] forState:UIControlStateHighlighted];
    [resetButton addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
     */
    
}

- (void)showSetting:(UIButton *)sender
{
    
    SRSettingViewController *settingViewController = [[SRSettingViewController alloc] init];
    settingViewController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    settingViewController.title = NSLocalizedString(@"Setting", @"setting");
    navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    settingViewController.navigationItem.rightBarButtonItem = doneButton;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        navController.view.frame = self.view.frame;
    } else {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        navController.view.frame = CGRectMake(0, 0, 540, 620);
    }
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:navController animated:YES];
    
    if (_measureMode == CameraAngleMeasure) {
        [self.viewControllerDelegate hideCameraView];
    }
     
    
}

#pragma mark settingViewController delegate

- (void)changeTextIndicatorStatus
{
    _textIndicatorIsOff = !_textIndicatorIsOff;
}

- (void)done:(UIBarButtonItem *)sender
{
    
    [self dismissModalViewControllerAnimated:YES];
    
    if (_measureMode == CameraAngleMeasure) {
        [self.viewControllerDelegate startCameraView];
        if (_clickCount > 1) {
            [self.viewControllerDelegate showStoredImage];
        }
    }

}

/*
- (void)reset:(UIButton *)sender
{
    if (_clickCount == 0) {
        if (self.motionManager.isDeviceMotionAvailable) {
            [self.motionManager stopDeviceMotionUpdates];
            [self.motionManager startDeviceMotionUpdates];
            
        }
    } else {
        
    }
   
}
 */


- (void)addPlusButtons
{
    
    // Configure gray view;
    self.grayView = [[UIView alloc] initWithFrame:self.view.frame];    
    self.grayView.backgroundColor = [UIColor blackColor];
    self.grayView.alpha = 0.0f;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(modeClick:)];
    [self.grayView addGestureRecognizer:tapGesture];
    [self.view addSubview:self.grayView];
    
    // Add mode button
    self.modeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.modeButton.frame = CGRectMake(10, self.view.frame.size.height - 70, 60, 60);
    } else {
        self.modeButton.frame = CGRectMake(30, self.view.frame.size.height - 120, 90, 90);
    }
    [self.modeButton setImage:[UIImage imageNamed:@"ModeButton"] forState:UIControlStateNormal];
    [self.modeButton setImage:[UIImage imageNamed:@"ModeButtonD"] forState:UIControlStateHighlighted];
    [self.view addSubview:self.modeButton];
    [self.modeButton addTarget:self action:@selector(modeClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // Add angle measure button for test
    
    self.angleMeasureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //self.angleMeasureButton.frame = CGRectMake(80, self.view.frame.size.height - 70, 50, 50);
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.angleMeasureButton.frame = CGRectMake(15, self.view.frame.size.height - 65, 50, 50);
    } else {
        self.angleMeasureButton.frame = CGRectMake(35, self.view.frame.size.height - 115, 80, 80);

    }
    [self.angleMeasureButton setImage:[UIImage imageNamed:@"AngleMeasureButton"] forState:UIControlStateNormal];
    [self.angleMeasureButton setImage:[UIImage imageNamed:@"AngleMeasureButtonD"] forState:UIControlStateHighlighted];
    self.angleMeasureButton.hidden = YES;
    [self.angleMeasureButton addTarget:self action:@selector(selectAngleMeasureButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.angleMeasureButton];
    
    self.slopeMeasureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //self.slopeMeasureButton.frame = CGRectMake(135, self.view.frame.size.height - 80, 50, 50);
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.slopeMeasureButton.frame = CGRectMake(15, self.view.frame.size.height - 65, 50, 50);
    } else {
        self.slopeMeasureButton.frame = CGRectMake(35, self.view.frame.size.height - 115, 80, 80);
        
    }
    [self.slopeMeasureButton setImage:[UIImage imageNamed:@"SlopeMeasureButton"] forState:UIControlStateNormal];
    [self.slopeMeasureButton setImage:[UIImage imageNamed:@"SlopeMeasureButtonD"] forState:UIControlStateHighlighted];
    self.slopeMeasureButton.hidden = YES;
    [self.slopeMeasureButton addTarget:self action:@selector(selectSlopeMeasureButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.slopeMeasureButton];
    
    
    self.dihedralMeasureButton = [UIButton buttonWithType:UIButtonTypeCustom];

    //self.dihedralMeasureButton.frame = CGRectMake(190, self.view.frame.size.height - 95, 50, 50);
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.dihedralMeasureButton.frame = CGRectMake(15, self.view.frame.size.height - 65, 50, 50);
    } else {
        self.dihedralMeasureButton.frame = CGRectMake(35, self.view.frame.size.height - 115, 80, 80);
        
    }
    [self.dihedralMeasureButton setImage:[UIImage imageNamed:@"DihedralAngleMeasureButton"] forState:UIControlStateNormal];
    [self.dihedralMeasureButton setImage:[UIImage imageNamed:@"DihedralAngleMeasureButtonD"] forState:UIControlStateHighlighted];
    self.dihedralMeasureButton.hidden = YES;
    [self.dihedralMeasureButton addTarget:self action:@selector(selectDihedralMeasureButton:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.dihedralMeasureButton];
    
    self.plainLineMeasureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //self.plainLineMeasureButton.frame = CGRectMake(245, self.view.frame.size.height - 115, 50, 50);
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.plainLineMeasureButton.frame = CGRectMake(15, self.view.frame.size.height - 65, 50, 50);
    } else {
        self.plainLineMeasureButton.frame = CGRectMake(35, self.view.frame.size.height - 115, 80, 80);
        
    }
    [self.plainLineMeasureButton setImage:[UIImage imageNamed:@"PlainLineAngleMeasureButton"] forState:UIControlStateNormal];
    [self.plainLineMeasureButton setImage:[UIImage imageNamed:@"PlainLineAngleMeasureButtonD"] forState:UIControlStateHighlighted];
    self.plainLineMeasureButton.hidden = YES;
    [self.plainLineMeasureButton addTarget:self action:@selector(selectPlainLineMeasureButton:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.plainLineMeasureButton];
    
    
    // Add Camera angle measure button
    self.cameraAngleMeasureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //self.angleMeasureButton.frame = CGRectMake(80, self.view.frame.size.height - 70, 50, 50);
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.cameraAngleMeasureButton.frame = CGRectMake(15, self.view.frame.size.height - 65, 50, 50);
    } else {
        self.cameraAngleMeasureButton.frame = CGRectMake(35, self.view.frame.size.height - 115, 80, 80);
        
    }
    [self.cameraAngleMeasureButton setImage:[UIImage imageNamed:@"CameraAngleButton"] forState:UIControlStateNormal];
    [self.cameraAngleMeasureButton setImage:[UIImage imageNamed:@"CameraAngleButtonD"] forState:UIControlStateHighlighted];
    self.cameraAngleMeasureButton.hidden = YES;
    [self.cameraAngleMeasureButton addTarget:self action:@selector(selectCameraAngleMeasureButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cameraAngleMeasureButton];

    
    // Set the highlight button
    [self setHighlightButton];
}

- (void)setHighlightButton
{
    switch (_measureMode) {
        case AngleMeasure:
            self.angleMeasureButton.highlighted = YES;
            break;
        case SlopeMeasure:
            self.slopeMeasureButton.highlighted = YES;
            break;
        case DihedralAngleMeasure:
            self.dihedralMeasureButton.highlighted = YES;
            break;
        case LinePlainAngleMeasure:
            self.plainLineMeasureButton.highlighted = YES;
            break;
        case CameraAngleMeasure:
            self.cameraAngleMeasureButton.highlighted = YES;
            break;
            
        default:
            break;
    }
}

/*
- (void)liteMeasure:(UIButton *)sender
{
    AudioServicesPlaySystemSound(self.soundFileObject);
    switch (_measureMode) {
        case AngleMeasure:
            [self angleMeasure];
            break;
        case CameraAngleMeasure:
            [self cameraAngleMeasure];
            break;
            
        default:
            break;
    }
    
}
*/
// In Lite version, action of press measure button
- (void)angleMeasure
{
    switch (_clickCount) {
        case 0:
            _clickCount = 1;
            [self.angleMeasureEngine storeFirstLine];
            if (!_textIndicatorIsOff) {
                [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm second Vector.", @"press measure button to confirm second vector")];
            }
            break;
        case 1:
            _clickCount = 2;
            [self.angleMeasureEngine storeSecondLine];
            if (!_textIndicatorIsOff) {
                [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to start a new measure.", @"press measure button to start a new measure")];
            }
            break;
        case 2:
            _clickCount = 0;
            [self.angleMeasureEngine clearStore];
            self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",0.0f];
            self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",0.0f];
            if (!_textIndicatorIsOff) {
                [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm first Vector.", @"press measure button to confirm first line")];
            }
            break;
        default:
            break;
    }
}

- (void)cameraAngleMeasure
{
    switch (_clickCount) {
        case 0:
            _clickCount = 1;
            [self.cameraAngleMeasureEngine storePlain];// 确认要测量的角度所在的平面
            if (!_textIndicatorIsOff) {
                [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button take a snapshot to measure angle.", @"press Measure button take a snapshot to measure angle.")];
            }
            break;
        case 1:
            _clickCount = 2;
            [self.cameraAngleMeasureEngine confirmDisplayPlain]; //在完成照相后确认在屏幕上显示的圆盘的平面
            [self.viewControllerDelegate showStillImage];
            if (!_textIndicatorIsOff) {
                [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm first Vector.", @"press measure button to confirm first line")];
            }
            break;
        case 2:
            _clickCount = 3;
            [self.cameraAngleMeasureEngine confirmFirstLine];  //确认第一条线
            if (!_textIndicatorIsOff) {
                [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm second Vector.", @"press measure button to confirm second vector")];
            }
            break;
        case 3:
            _clickCount = 4;
            [self.cameraAngleMeasureEngine confirmSecondLine]; //确认第二条线
            if (!_textIndicatorIsOff) {
                [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to start a new measure.", @"press measure button to start a new measure")];
            }
            break;
        case 4:
            _clickCount = 0;
            [self.cameraAngleMeasureEngine clearBuffers]; //清除缓存，归零
            [self.viewControllerDelegate hideStillImage];
            self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",0.0f];
            self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",0.0f];
            if (!_textIndicatorIsOff) {
                [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Confirm button to confirm the surface where the angle is to be measured.", @"Press Confirm button to confirm the surface where the angle is to be measured.")];
            }
            
        default:
            break;
    }

}


// Action of press measure button
- (void)measure:(UIButton *)sender
{
    AudioServicesPlaySystemSound(self.soundFileObject);
    switch (_measureMode) {
        case AngleMeasure:
            [self angleMeasure];
            break;
        case SlopeMeasure:
        {
            switch (_clickCount) {
                case 0:
                    [self.slopeMeasureEngine storeSlope];
                    _clickCount = 1;
                    if (!_textIndicatorIsOff) {
                    [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to start a new measure.", @"press measure button to start a new measure")];
                    }
                    break;
                case 1:
                    [self.slopeMeasureEngine clearSlope];
                    _clickCount = 0;
                    self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",0.0f];
                    self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",0.0f];
                    if (!_textIndicatorIsOff) {
                    [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press measure button to confirm Slope Angle.", @"press measure button to confirm slope angle")];
                    }
                    break;
                default:
                    break;
            }
        }
            
            break;
        case DihedralAngleMeasure:
        {
            switch (_clickCount) {
                case 0:
                    [self.dihedralAngleMeasureEngine storeFirstPlain];
                    _clickCount = 1;
                    if (!_textIndicatorIsOff) {
                    [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm second Face.", @"press measure button to confirm second plain")];
                    }
                    break;
                case 1:
                    [self.dihedralAngleMeasureEngine storeSecondPlain];
                    _clickCount = 2;
                if (!_textIndicatorIsOff) {
                    [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to start a new measure.", @"press measure button to start a new measure")];
                }
                    break;
                case 2:
                    [self.dihedralAngleMeasureEngine clearPlains];
                    _clickCount = 0;
                    self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",0.0f];
                    self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",0.0f];
                    if (!_textIndicatorIsOff) {
                    [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm first Face.", @"press measure button to confirm first face")];
                    }
                    break;
                default:
                    break;
            }
        }
            break;
        case LinePlainAngleMeasure:
        {

            switch (_clickCount) {
                case 0:
                    [self.linePlainAngleMeasureEngine storePlain];
                    _clickCount = 1;
                    if (!_textIndicatorIsOff) {
                    [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm a Vector.", @"press measure button to confirm a vector")];
                    }
                    break;
                case 1:
                    [self.linePlainAngleMeasureEngine storeLine];
                    _clickCount = 2;
                    if (!_textIndicatorIsOff) {
                    [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to start a new measure", @"press measure button to start a new measure")];
                    }
                    break;
                case 2:
                    [self.linePlainAngleMeasureEngine clearLineAndPlain];
                    _clickCount = 0;
                    self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",0.0f];
                    self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",0.0f];
                    if (!_textIndicatorIsOff) {
                    [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm a Face.", @"press measure button to confirm a face")];
                    }
                    break;
                default:
                    break;
            }
        }
            break;
        case CameraAngleMeasure:
        {
            [self cameraAngleMeasure];
                    }
            break;
        default:
            break;
    }
}

// Change the measure mode
- (void)modeClick:(UIButton *)sender
{
    // Animation of gray view
    if (_modeStatus == modeHide) {
        NSLog(@"show");
        [self setHighlightButton];
        [self showSelectButtonsAndGrayView];
        
    } else {
        NSLog(@"hide");
        [self hideSelectButtonsAndGrayView];
        
    }

}

- (void)showSelectButtonsAndGrayView
{
    self.plainLineMeasureButton.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
            self.grayView.alpha = 0.8;
    }];
    
    float deltaiPhone = (self.view.frame.size.height - 70) - self.modeButton.frame.origin.y;
    float deltaiPad = (self.view.frame.size.height - 120) - self.modeButton.frame.origin.y;
    
    [UIView animateWithDuration:0.2 animations:^{
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
                self.plainLineMeasureButton.frame = CGRectMake(260, self.view.frame.size.height - 165 - deltaiPhone , 50, 50);
            } else {
                self.plainLineMeasureButton.frame = CGRectMake(440, self.view.frame.size.height - 235 - deltaiPad, 80, 80);
                
            }
            
        } completion:^(BOOL finished) {
            self.dihedralMeasureButton.hidden = NO;
            [UIView animateWithDuration:0.15 animations:^{
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
                    self.dihedralMeasureButton.frame = CGRectMake(200, self.view.frame.size.height - 140 - deltaiPhone, 50, 50);
                } else {
                    self.dihedralMeasureButton.frame = CGRectMake(340, self.view.frame.size.height - 205 - deltaiPad, 80, 80);
                    
                }
            } completion:^(BOOL finished) {
                self.slopeMeasureButton.hidden = NO;
                
                [UIView animateWithDuration:0.1 animations:^{
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
                        self.slopeMeasureButton.frame = CGRectMake(140, self.view.frame.size.height - 115 - deltaiPhone, 50, 50);
                    } else {
                        self.slopeMeasureButton.frame = CGRectMake(240, self.view.frame.size.height - 175 - deltaiPad, 80, 80);
                        
                    }
                    
                } completion:^(BOOL finished) {
                    self.angleMeasureButton.hidden = NO;
                    self.cameraAngleMeasureButton.hidden = NO;
                    [UIView animateWithDuration:0.05 animations:^{
                        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
                            self.angleMeasureButton.frame = CGRectMake(80, self.view.frame.size.height - 90 - deltaiPhone, 50, 50);
                            self.cameraAngleMeasureButton.frame = CGRectMake(15, self.view.frame.size.height - 135 - deltaiPhone, 50, 50);
                        } else {
                            self.angleMeasureButton.frame = CGRectMake(140, self.view.frame.size.height - 145 - deltaiPad, 80, 80);
                            self.cameraAngleMeasureButton.frame = CGRectMake(35, self.view.frame.size.height - 215 - deltaiPad, 80, 80);
                            
                            
                        }
                    } completion:^(BOOL finished) {
                        _modeStatus = modeShow;
                    }];
                }];
                
            }];
        }];

}

- (void)hideSelectButtonsAndGrayView
{
    [UIView animateWithDuration:0.5 animations:^{
            self.grayView.alpha = 0.0;
    }];
    float deltaiPhone = (self.view.frame.size.height - 70) - self.modeButton.frame.origin.y;
    float deltaiPad = (self.view.frame.size.height - 120) - self.modeButton.frame.origin.y;

    [UIView animateWithDuration:0.05
                         animations:^{
                             if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
                                 self.angleMeasureButton.frame = CGRectMake(15, self.view.frame.size.height - 65  - deltaiPhone, 50, 50);
                                 self.cameraAngleMeasureButton.frame = CGRectMake(15, self.view.frame.size.height - 65  - deltaiPhone, 50, 50);
                             } else {
                                 self.angleMeasureButton.frame = CGRectMake(35, self.view.frame.size.height - 115 - deltaiPad, 80, 80);
                                 self.cameraAngleMeasureButton.frame = CGRectMake(35, self.view.frame.size.height - 115 - deltaiPad, 80, 80);
                                 
                             }                         }
                         completion:^(BOOL finished) {
                             self.angleMeasureButton.hidden = YES;
                             self.cameraAngleMeasureButton.hidden = YES;
                             [UIView animateWithDuration:0.1 animations:^{
                                 if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
                                     self.slopeMeasureButton.frame = CGRectMake(15, self.view.frame.size.height - 65 - deltaiPhone, 50, 50);
                                 } else {
                                     self.slopeMeasureButton.frame = CGRectMake(35, self.view.frame.size.height - 115 - deltaiPad, 80, 80);
                                     
                                 }
                             } completion:^(BOOL finished) {
                                 self.slopeMeasureButton.hidden = YES;
                                 [UIView animateWithDuration:0.15 animations:^{
                                     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
                                         self.dihedralMeasureButton.frame = CGRectMake(15, self.view.frame.size.height - 65 - deltaiPhone, 50, 50);
                                     } else {
                                         self.dihedralMeasureButton.frame = CGRectMake(35, self.view.frame.size.height - 115 - deltaiPad, 80, 80);
                                         
                                     }
                                 } completion:^(BOOL finished) {
                                     self.dihedralMeasureButton.hidden = YES;
                                     [UIView animateWithDuration:0.2 animations:^{
                                         if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
                                             self.plainLineMeasureButton.frame = CGRectMake(15, self.view.frame.size.height - 65 - deltaiPhone, 50, 50);
                                         } else {
                                             self.plainLineMeasureButton.frame = CGRectMake(35, self.view.frame.size.height - 115 - deltaiPad, 80, 80);
                                             
                                         }
                                     } completion:^(BOOL finished) {
                                         self.plainLineMeasureButton.hidden = YES;
                                         _modeStatus = modeHide;
                                     }];
                                 }];
                             }];
                         }];
   
}

- (void)modeChange
{
    [self unHightLightButtons];
    //[self hideSelectButtons];
    [self modeClick:nil];
    self.displayLabel.text = @"0.0°";
    self.radDisplayLabel.text = @"0.00r";
    _clickCount = 0;

}

- (void)selectAngleMeasureButton:(UIButton *)sender
{
    _measureMode = AngleMeasure;
    [self.viewControllerDelegate hideCameraView];
    [self modeChange];
    [self modeClick:nil];
    
    if (!_textIndicatorIsOff) {
        [self.textIndicator showIndicatorWithString:NSLocalizedString(@"Vector Angle Measure Mode", @"Vector Angle measure mode") withCompletionHandler:^(BOOL finished) {
            [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm first Vector.", @"press measure button to confirm first line")];
        }];
    }
 
}

- (void)selectSlopeMeasureButton:(UIButton *)sender
{
#ifndef LITE_VERSION
    _measureMode = SlopeMeasure;
    [self.viewControllerDelegate hideCameraView];
    
    [self modeChange];
    if (!_textIndicatorIsOff) {
        [self.textIndicator showIndicatorWithString:NSLocalizedString(@"Slope Angle Measure Mode", @"slope angle measure mode") withCompletionHandler:^(BOOL finished) {
            [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm a Slope.", @"press measure button to confirm a slope")];
        }];
    }
#else
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:K_SLOPE_ANGLE_MODE]) {
        _measureMode = SlopeMeasure;
        [self.viewControllerDelegate hideCameraView];
        
        [self modeChange];
        if (!_textIndicatorIsOff) {
            [self.textIndicator showIndicatorWithString:NSLocalizedString(@"Slope Angle Measure Mode", @"slope angle measure mode") withCompletionHandler:^(BOOL finished) {
                [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm a Slope.", @"press measure button to confirm a slope")];
            }];
        }
    } else {
        [self modeClick:nil];
        [self showBuyAlert];
    }
    
#endif
}

- (void)selectDihedralMeasureButton:(UIButton *)sender
{
#ifndef LITE_VERSION

    _measureMode = DihedralAngleMeasure;
    [self.viewControllerDelegate hideCameraView];

    [self modeChange];
    if (!_textIndicatorIsOff) {
        [self.textIndicator showIndicatorWithString:NSLocalizedString(@"Dihedral Angle Measure Mode", @"dihedral angle measure mode") withCompletionHandler:^(BOOL finished) {
            [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm first Face.", @"press measure button to confirm first face")];
        }];
    }
    
#else
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:K_DIHEDRAL_ANGLE_MODE]){
        _measureMode = DihedralAngleMeasure;
        [self.viewControllerDelegate hideCameraView];
        
        [self modeChange];
        if (!_textIndicatorIsOff) {
            [self.textIndicator showIndicatorWithString:NSLocalizedString(@"Dihedral Angle Measure Mode", @"dihedral angle measure mode") withCompletionHandler:^(BOOL finished) {
                [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm first Face.", @"press measure button to confirm first face")];
            }];
        }
  
    } else {
        [self modeClick:nil];
        
        [self showBuyAlert];
    }

#endif

}

- (void)selectPlainLineMeasureButton:(UIButton *)sender
{
    
#ifndef LITE_VERSION

    _measureMode = LinePlainAngleMeasure;
    [self.viewControllerDelegate hideCameraView];
   
    [self modeChange];
    if (!_textIndicatorIsOff) {
        [self.textIndicator showIndicatorWithString:NSLocalizedString(@"Line Face Angle Measure Mode", @"line plain angle measure mode") withCompletionHandler:^(BOOL finished) {
            [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm a Face.", @"press measure button to confirm a face")];
        }];
    }
    
#else
    if ([[NSUserDefaults standardUserDefaults] boolForKey:K_LINE_PLANE_ANGLE_MODE]){
        _measureMode = LinePlainAngleMeasure;
        [self.viewControllerDelegate hideCameraView];
        
        [self modeChange];
        if (!_textIndicatorIsOff) {
            [self.textIndicator showIndicatorWithString:NSLocalizedString(@"Line Face Angle Measure Mode", @"line plain angle measure mode") withCompletionHandler:^(BOOL finished) {
                [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Measure button to confirm a Face.", @"press measure button to confirm a face")];
            }];
        }

    } else {        
        [self modeClick:nil];        
        [self showBuyAlert];
    }

#endif

}

- (void)selectCameraAngleMeasureButton:(UIButton *)sender
{
    [self.viewControllerDelegate hideStillImage];
    
#ifdef LITE_VERSION
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:K_CAMERA_ANGLE_MODE]){
        [self changeToCameraAngleMode];
    } else {
        NSNumber *cameraAngleModeCounter = [defaults objectForKey:@"Camera Angle Mode Counter"];
        int counter = [cameraAngleModeCounter intValue];
        if (counter > 0) {
            [self changeToCameraAngleMode];
            counter--;
            cameraAngleModeCounter = [NSNumber numberWithInt:counter];
            [defaults setObject:cameraAngleModeCounter forKey:@"Camera Angle Mode Counter"];
            [defaults synchronize];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Prompt", @"prompt") message:[NSString stringWithFormat:@"%@%d",NSLocalizedString(@"The times you can use Camera Angle Mode:", @"the times you can use Camera Angle Mode:"),counter] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            [self modeClick:nil];
            
            [self showBuyAlert];
        }

    }
    
       
#else
    [self changeToCameraAngleMode];

#endif
    
}

- (void)changeToCameraAngleMode
{
    _measureMode = CameraAngleMeasure;
    [self.viewControllerDelegate startCameraView];
    NSLog(@"select camera mode");
    [self modeChange];
    if (!_textIndicatorIsOff) {
        [self.textIndicator showIndicatorWithString:NSLocalizedString(@"Camera Angle Mode", @"camera angle mode") withCompletionHandler:^(BOOL finished) {
            [self.textIndicator showDelayIndicatorWithString:NSLocalizedString(@"Press Confirm button to confirm the surface where the angle is to be measured.", @"Press Confirm button to confirm the surface where the angle is to be measured.")];
        }];
    }
    
    [self modeClick:nil];
}

- (void)unHightLightButtons
{
    self.angleMeasureButton.highlighted = NO;
    self.slopeMeasureButton.highlighted = NO;
    self.dihedralMeasureButton.highlighted = NO;
    self.plainLineMeasureButton.highlighted = NO;
    self.cameraAngleMeasureButton.highlighted = NO;
}

#ifdef LITE_VERSION
- (void)showBuyAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Prompt", @"prompt")   message:NSLocalizedString(@"This mode is not available now, just buy it!",@"This mode is not available now, just buy it!") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"cancel") otherButtonTitles:NSLocalizedString(@"Purchase",@"purchase"), nil];
    [alert show];
}


- (void)showInAppPurchase
{
    SRInAppPurchaseViewController *inAppPurchaseViewController = [[SRInAppPurchaseViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:inAppPurchaseViewController];
    inAppPurchaseViewController.title = NSLocalizedString(@"In App Purchase", @"In App Purchase");
    navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    inAppPurchaseViewController.navigationItem.leftBarButtonItem = doneButton;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        navController.view.frame = self.view.frame;
    } else {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        navController.view.frame = CGRectMake(0, 0, 540, 620);
    }
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navController animated:YES];
    
    if (_measureMode == CameraAngleMeasure) {
        [self.viewControllerDelegate hideCameraView];
    }
}
#endif

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Purchase",@"purchase")]) {
        /*
        NSString *path = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@",APP_ID_FULL_VERSION];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
         */
#ifdef LITE_VERSION
        [self showInAppPurchase];
#endif
    } else if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Rate", @"rate")]) {
        // Rate
#ifdef LITE_VERSION
        NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",APP_ID_LITE_VERSION];
#else
        NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",APP_ID_FULL_VERSION];
#endif
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *everRated = [NSNumber numberWithBool:YES];
        [defaults setObject:everRated forKey:@"Ever Rated"];
        [defaults synchronize];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Update", @"Update")]){
        
#ifdef LITE_VERSION
        NSString *path = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@",APP_ID_LITE_VERSION];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
#else
        NSString *path = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@",APP_ID_FULL_VERSION];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
#endif
        
    }
}


#pragma mark - Admob banner

#ifdef LITE_VERSION

- (void)setupAdBanner
{
    // Initialize the banner off the screen so that it animates up when displaying
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.adBanner = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)] ;
        self.appleAdBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 50)];
    } else {
        // The device is iPad
        self.adBanner = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height, 768, 90)] ;
        self.appleAdBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 768, 66)];
    }
    
    // Configure ad banner
    self.adBanner.adUnitID = AD_UNIT_ID;
    self.adBanner.delegate = self;
    [self.adBanner setRootViewController:self];
    [self.view addSubview:self.adBanner];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *iAdFailedTimes = [defaults objectForKey:@"iAd Failed Times"];
    if ([iAdFailedTimes intValue] > 4) {
        [self.adBanner loadRequest:[self createRequest]];
        NSLog(@"load google ad");
    } else {
        // Configure iAd
        self.appleAdBanner.delegate = self;
        [self.view addSubview:self.appleAdBanner];
        NSLog(@"load iad");
    }
    
    
    
                              
    
    
}

- (GADRequest *)createRequest
{
    GADRequest *request = [GADRequest request];
    //request.testDevices =[NSArray arrayWithObjects:@"123cd7ade2dc72c6d993c0bcd7cf9ac883499a85",nil];

    return request;
}

#pragma mark GADBannerViewDelegate

// Since we've received an ad, let's go ahead and set the frame to display it
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    NSLog(@"ad received");
    [UIView animateWithDuration:1.0 animations:^{
        
        if (self.appleAdBanner.frame.origin.y == self.view.frame.size.height) {
            view.frame = CGRectMake(0.0, self.view.frame.size.height - view.frame.size.height, view.frame.size.width, view.frame.size.height);
            [self changeButtonPosition];
        }

    }];
    NSLog(@"Received ad");
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"Failed to receive google ad with error:%@",[error localizedDescription]);
}
                              
                              
#pragma mark   iAd delegate
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
   return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"Apple ad loaded");
    [UIView animateWithDuration:1.0 animations:^{
        if (self.adBanner.frame.origin.y == self.view.frame.size.height) {
            banner.frame = CGRectMake(0.0f, self.view.frame.size.height - banner.frame.size.height, banner.frame.size.width, banner.frame.size.height);
            [self changeButtonPosition];
        }
        
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to receive apple ad with error:%@",[error localizedDescription]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *iAdFailedTimes = [defaults objectForKey:@"iAd Failed Times"];
    iAdFailedTimes = [NSNumber numberWithInt:[iAdFailedTimes intValue] + 1];
    [defaults setObject:iAdFailedTimes forKey:@"iAd Failed Times"];
    
    [self.adBanner loadRequest:[self createRequest]];
    NSLog(@"load google ad");
}

- (void)changeButtonPosition
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.settingButton.frame = CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - 110, 50, 50);
        self.modeButton.frame = CGRectMake(10, self.view.frame.size.height - 120, 60, 60);
        self.angleMeasureButton.frame = CGRectMake(self.angleMeasureButton.frame.origin.x, self.angleMeasureButton.frame.origin.y - 50, self.angleMeasureButton.frame.size.width, self.angleMeasureButton.frame.size.height);
        self.slopeMeasureButton.frame = CGRectMake(self.slopeMeasureButton.frame.origin.x, self.slopeMeasureButton.frame.origin.y - 50, self.slopeMeasureButton.frame.size.width, self.slopeMeasureButton.frame.size.height);
        self.dihedralMeasureButton.frame = CGRectMake(self.dihedralMeasureButton.frame.origin.x, self.dihedralMeasureButton.frame.origin.y - 50, self.dihedralMeasureButton.frame.size.width, self.dihedralMeasureButton.frame.size.height);
        self.plainLineMeasureButton.frame = CGRectMake(self.plainLineMeasureButton.frame.origin.x, self.plainLineMeasureButton.frame.origin.y - 50, self.plainLineMeasureButton.frame.size.width, self.plainLineMeasureButton.frame.size.height);
        
        
    } else {
        self.settingButton.frame = CGRectMake(self.view.frame.size.width - 110, self.view.frame.size.height - 180, 60, 60);
        self.modeButton.frame = CGRectMake(30, self.view.frame.size.height - 210, 90, 90);
        self.angleMeasureButton.frame = CGRectMake(self.angleMeasureButton.frame.origin.x, self.angleMeasureButton.frame.origin.y - 90, self.angleMeasureButton.frame.size.width, self.angleMeasureButton.frame.size.height);
        self.slopeMeasureButton.frame = CGRectMake(self.slopeMeasureButton.frame.origin.x, self.slopeMeasureButton.frame.origin.y - 90, self.slopeMeasureButton.frame.size.width, self.slopeMeasureButton.frame.size.height);
        self.dihedralMeasureButton.frame = CGRectMake(self.dihedralMeasureButton.frame.origin.x, self.dihedralMeasureButton.frame.origin.y - 90, self.dihedralMeasureButton.frame.size.width, self.dihedralMeasureButton.frame.size.height);
        self.plainLineMeasureButton.frame = CGRectMake(self.plainLineMeasureButton.frame.origin.x, self.plainLineMeasureButton.frame.origin.y - 90, self.plainLineMeasureButton.frame.size.width, self.plainLineMeasureButton.frame.size.height);
        
    }

}

#endif



#pragma mark - OpenGL ES 2.0 configuration methods

- (void)setupOpenGL
{
    // Step 1: Configure view
    
    // Verify the type of view created automatically by the Interface Builder storyboard
    GLKView  *view = (GLKView *)self.view;
    
    // Set the view's background color to clearColor so as to show the background image from ViewController.
    view.backgroundColor = [UIColor clearColor];
    
    // Use high resolution depth buffer;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    
    // Step 2: Configure context
    [self configureContextWithView:view];
    
    // Step 3: Configure basic effect
    [self configureBasicEffect];
    
    // Step 4: Load Model
    [self loadModel];
    
    // Step 5: Setup trick ball rotation
    //[self setupTrackBallRotation];
    
    // Do the measurement
    

}


- (void)configureContextWithView:(GLKView *)view
{
    // Create an OpenGL ES 2.0 context and provide it to the view
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // Make the new context current
    [AGLKContext setCurrentContext:view.context];
    
    // set clear color to transparent
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);

    
    // Configure context
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    //glEnable(GL_BLEND);
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //glDisable(GL_DEPTH_TEST);

}

- (void)configureBasicEffect
{
    // Initial base effect
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    // Enable light
    self.baseEffect.light0.enabled = GL_TRUE;
    //self.baseEffect.light1.enabled = GL_TRUE;
    
    // Configure basic light
    self.baseEffect.light0.position = GLKVector4Make(-2,2, -3.0, 1);
    //self.baseEffect.light0.spotCutoff = 180;
    //self.baseEffect.light0.spotExponent = 100;
    //self.baseEffect.light0.spotDirection = GLKVector3Make(-1, -1, -0.5);
    //self.baseEffect.light0.linearAttenuation = 0;
    //self.baseEffect.light0.quadraticAttenuation = 0;
    
    //self.baseEffect.light1.position = GLKVector4Make(0.5, 0.5, 0, 1);
    //self.baseEffect.light1.ambientColor  = GLKVector4Make(1.0, 0.8, 0.4, 1);
    
    // Set lighting type
    self.baseEffect.lightingType = GLKLightingTypePerPixel;
}

- (void)loadModel
{
    // The model manager loads model and sends the data to GPU. Each loaded model can be accessed by name.
    NSString *modelsPath = [[NSBundle mainBundle] pathForResource:@"model" ofType:@"modelplist"];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelsPath];
    
    // Load model used to draw the scene
    self.axis = [self.modelManager modelNamed:@"axis"];
    self.degree = [self.modelManager modelNamed:@"degree"];
    self.circle = [self.modelManager modelNamed:@"circle"];
    self.plain = [self.modelManager modelNamed:@"plain"];
    self.chip = [self.modelManager modelNamed:@"chip"];
    self.target = [self.modelManager modelNamed:@"target"];

    
    NSAssert(self.target != nil, @"Failed to load model");

}

/*
- (void)setupTrackBallRotation
{
    self.trackBallController = [[SRTrackBallController alloc] initWithView:self.view trackBallRadius:(self.view.frame.size.width - 40) / 2];
    [self.trackBallController startTrackBallUpdate];
}


- (GLKMatrix4)multiplyTrackBallRotationWithModelViewMatrix:(GLKMatrix4)modelViewMatrix
{
    // Track ball rotation
    GLKQuaternion orientation = [self.trackBallController trackBallOrientation];
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(orientation));
    return modelViewMatrix;

}
*/

#pragma mark OpenGL ES draw methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Clear context
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT];

    // Basic configuration
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    if (self.view.frame.size.height / self.view.frame.size.width < 1.6){
        self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35),aspectRatio,4,20.0f);
    } else {
        self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(40),aspectRatio,4,20.0f);

    }
    
    // Prepare to draw
    [self.modelManager prepareToDraw];
    
    // Draw measurement
    [self drawProVersion];

    
    
}

- (void)drawCircle
{
    // Configure lights
    //self.baseEffect.light0.ambientColor = GLKVector4Make(0.9, 0.9, 0.9, 1);
    //self.baseEffect.light0.diffuseColor = GLKVector4Make(0.8, 0.8, 0.8, 1);
    //self.baseEffect.material.specularColor = GLKVector4Make(0.3, 0.1, 0.1, 1);
    
    self.baseEffect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1);
    //self.baseEffect.light0.diffuseColor = GLKVector4Make(201.0/255.0, 204.0/255.0,206.0/255.0, 1);
    //self.baseEffect.light0.diffuseColor = GLKVector4Make(218/255.0, 219/255.0,225/255.0, 1);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(231/255.0, 231/255.0,235/255.0, 1);
    self.baseEffect.material.specularColor = GLKVector4Make(0.1,0.1,0.1, 1);

    // Draw
    [self.baseEffect prepareToDraw];
    [self.circle draw];
}

- (void)drawDegree
{
    // Configure lights
    
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.1, 0.1, 0.1, 1);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.1, 0.1, 0.1, 1);
    self.baseEffect.material.specularColor = GLKVector4Make(0.1, 0.1, 0.1, 1);
    
    // Draw
    [self.baseEffect prepareToDraw];
    [self.degree draw];
}

- (void)drawAxis
{
   
    self.baseEffect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(218/255.0, 219/255.0,225/255.0, 1);
    self.baseEffect.material.specularColor = GLKVector4Make(0.1, 0.1, 0.1, 1);
    
    // Draw
    [self.baseEffect prepareToDraw];
    [self.axis draw];
}

- (void)drawPlain
{
    self.baseEffect.light0.ambientColor = GLKVector4Make(1, 1, 0, 1);
    //self.baseEffect.light0.diffuseColor = GLKVector4Make(0.8, 0.8, 0.8, 1);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(242.0/255.0, 210.0/255.0,120.0/255.0, 1);
    self.baseEffect.material.specularColor = GLKVector4Make(0.3, 0.3, 0.1, 1);
    
    // Draw
    [self.baseEffect prepareToDraw];
    [self.plain draw];

}

- (void)drawChip
{
    self.baseEffect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1);
    //self.baseEffect.light0.diffuseColor = GLKVector4Make(232/255.0, 57/255.0, 57/255.0, 1);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(124/255.0, 186.0/255.0, 84/255.0, 1);

    self.baseEffect.material.specularColor = GLKVector4Make(0.1, 0.3, 0.1, 1);
    
    // Draw
    [self.baseEffect prepareToDraw];
    [self.chip draw];
}

- (void)drawAnotherChip
{
    self.baseEffect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(100.0/255.0, 152.0/255.0, 225.0/255.0, 1);
    self.baseEffect.material.specularColor = GLKVector4Make(0.1, 0.4, 0.9, 1);
    
    // Draw
    [self.baseEffect prepareToDraw];
    [self.chip draw];
}

- (void)drawTarget
{
    self.baseEffect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(218/255.0, 219/255.0,225/255.0, 1);
    self.baseEffect.material.specularColor = GLKVector4Make(0.1, 0.1, 0.1, 1);
    
    // Draw
    [self.baseEffect prepareToDraw];
    [self.target draw];
}

/*
- (void)drawLiteVersion
{
    switch (_measureMode) {
        case AngleMeasure:
            [self drawLineLineAngleMode];
            break;
        case CameraAngleMeasure:
            [self drawCameraAngleMode];
            break;
            
        default:
            break;
    }
}
 */

- (void)drawLineLineAngleMode
{
    switch (_clickCount) {
        case 0:
            
            // At the beginning ,there is no line set ,so just show free rotation of the axis and other items
            [self.angleMeasureEngine drawFreeRotationWithBaseEffect:self.baseEffect];
            
            break;
        case 1:
            // The user had set first line ,so show the line and free rotation
            [self.angleMeasureEngine drawFirstLineAndFreeRotationWithBaseEffect:self.baseEffect];
            self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",fabsf(self.angleMeasureEngine.freeAngle)];
            self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",fabsf(self.angleMeasureEngine.freeAngle) / 180 * M_PI];
            break;
        case 2:
            // The user had set the second line,so with angle measure engine,it has calculate the angle,show the final result
            [self.angleMeasureEngine drawFinalAngleMeasureWithBaseEffect:self.baseEffect];
            self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",fabsf(self.angleMeasureEngine.measureAngle)];
            self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",fabsf(self.angleMeasureEngine.measureAngle) / 180 * M_PI];
            
            break;
            
        default:
            break;
    }
}

- (void)drawCameraAngleMode
{
    switch (_clickCount) {
        case 0:
            // At the beginning,you need to confirm a plain that you want to measure angle on it
            [self.cameraAngleMeasureEngine drawFreePlainWithBaseEffect:self.baseEffect];
            break;
        case 1:
            // after confirm the plain,you need to take a photo,then
            [self.cameraAngleMeasureEngine drawCameraPlainWithBaseEffect:self.baseEffect];
            break;
        case 2:
            // After confirm a photo,the plain is confirmed,next you need to confirm lines
            [self.cameraAngleMeasureEngine drawCameraPlainWithOneLineWithBaseEffect:self.baseEffect];
            break;
        case 3:
            // After confirm a line,you need to confirm second line
            [self.cameraAngleMeasureEngine drawCameraPlainWithTwoLineWithBaseEffect:self.baseEffect];
            self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",fabsf(self.cameraAngleMeasureEngine.freeAngle)];
            self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",fabsf(self.cameraAngleMeasureEngine.freeAngle) / 180 * M_PI];
            break;
        case 4:
            // After confirm second line,you got the result
            [self.cameraAngleMeasureEngine drawFinalResultWithBaseEffect:self.baseEffect];
            self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",fabsf(self.cameraAngleMeasureEngine.measureAngle)];
            self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",fabsf(self.cameraAngleMeasureEngine.measureAngle) / 180 * M_PI];
            break;
            
            
        default:
            break;
    }

}


- (void)drawProVersion
{
    switch (_measureMode) {
        case AngleMeasure:
            [self drawLineLineAngleMode];
            break;
        case SlopeMeasure:
        {
            switch (_clickCount) {
                case 0:
                    [self.slopeMeasureEngine drawFreeSlopeWithBaseEffect:self.baseEffect];
                    self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",self.slopeMeasureEngine.freeSlope];
                    self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",self.slopeMeasureEngine.freeSlope / 180 * M_PI];
                    break;
                case 1:
                    [self.slopeMeasureEngine drawMeasureSlopeWithBaseEffect:self.baseEffect];
                    self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",self.slopeMeasureEngine.measureSlope];
                    self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",self.slopeMeasureEngine.measureSlope / 180 * M_PI];
                    
                    break;
                default:
                    break;
            }
        }
            break;
        case DihedralAngleMeasure:
        {
            switch (_clickCount) {
                case 0:
                    
                    // At the beginning ,there is no line set ,so just show free rotation of the axis and other items
                    [self.dihedralAngleMeasureEngine drawFreeRotationWithBaseEffect:self.baseEffect];
                    
                    break;
                case 1:
                    // The user had set first line ,so show the line and free rotation
                    [self.dihedralAngleMeasureEngine drawFirstPlainAndFreeRotationWithBaseEffect:self.baseEffect];
                    self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",self.dihedralAngleMeasureEngine.freeAngle];
                    self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",self.dihedralAngleMeasureEngine.freeAngle / 180 * M_PI];
                    break;
                case 2:
                    // The user had set the second line,so with angle measure engine,it has calculate the angle,show the final result
                    [self.dihedralAngleMeasureEngine drawFinalAngleMeasureWithBaseEffect:self.baseEffect];
                    self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",self.dihedralAngleMeasureEngine.measureAngle];
                    self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",self.dihedralAngleMeasureEngine.measureAngle / 180 * M_PI];
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case LinePlainAngleMeasure:
        {
            switch (_clickCount) {
                case 0:
                    
                    // At the beginning ,there is no line set ,so just show free rotation of the axis and other items
                    [self.linePlainAngleMeasureEngine drawFreeRotationPlainWithBaseEffect:self.baseEffect];
                    
                    break;
                case 1:
                    // The user had set first line ,so show the line and free rotation
                    [self.linePlainAngleMeasureEngine drawPlainAndFreeRotationLineWithBaseEffect:self.baseEffect];
                
                    self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",fabsf(self.linePlainAngleMeasureEngine.freeAngle)];
                    self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",fabsf(self.linePlainAngleMeasureEngine.freeAngle) / 180 * M_PI];
                    break;
                case 2:
                    // The user had set the second line,so with angle measure engine,it has calculate the angle,show the final result
                    [self.linePlainAngleMeasureEngine drawFinalAngleMeasureWithBaseEffect:self.baseEffect];
                    self.displayLabel.text = [NSString stringWithFormat:@"%4.1f°",fabsf(self.linePlainAngleMeasureEngine.measureAngle)];
                    self.radDisplayLabel.text = [NSString stringWithFormat:@"%4.2fr",fabsf(self.linePlainAngleMeasureEngine.measureAngle) / 180 * M_PI];
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case CameraAngleMeasure:
        {
            [self drawCameraAngleMode];
                    }
            break;
        default:
            break;
    }
}

#pragma mark - SR Angle Measure Engine Protocol
- (GLKQuaternion)deviceAttitude
{
    GLKQuaternion attitude = GLKQuaternionMake(self.motionManager.deviceMotion.attitude.quaternion.x, self.motionManager.deviceMotion.attitude.quaternion.y, self.motionManager.deviceMotion.attitude.quaternion.z, self.motionManager.deviceMotion.attitude.quaternion.w);
    return attitude;
}


@end
