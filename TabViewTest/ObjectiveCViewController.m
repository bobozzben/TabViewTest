//
//  ObjectiveCViewController.m
//  TabViewTest
//
//  Created by Ben_Mac on 2020/11/5.
//  Copyright © 2020 Ben_Mac. All rights reserved.
//

#import "ObjectiveCViewController.h"
#import <AudioToolbox/AudioToolbox.h>


@interface ObjectiveCViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *GoBackButton;
@property (weak, nonatomic) IBOutlet UIButton *Test1_Button;
@property (weak, nonatomic) IBOutlet UIButton *Test2_Button;
@property (weak, nonatomic) IBOutlet UIButton *Test3_Button;


@end

@implementation ObjectiveCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"設定左右按鍵 %@" , _goString  );
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"上一頁" style:UIBarButtonItemStyleDone target:self action:@selector(onBackItem)];
    self.navigationItem.leftBarButtonItems = @[backItem];

    NSString *path;
    // 循環所有看得到的目錄 NSBundle=是一個目錄（也可能是一個檔案）只有APP的目錄才能存取
    for (NSBundle *bundle in [NSBundle allBundles]) {
        NSLog(@"%@",bundle);
        path = [bundle pathForResource:@"*" ofType:@"caf"];
        if (path) {
            NSLog(@"%@",path);
            break;  // Here is your path.
        }
    }
    // 取得 com.apple.UIKit 系統路徑 (抓不到1091117)
    // NSString *mySoundFile = [[NSBundle mainBundle] pathForResource:@"Tink" ofType:@"caf"];  // APP的目錄
    NSString *opath = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"Tock" ofType:@"aiff"];
    NSLog(@"Audio Path %@",path);
    if ( opath != nil ) {
       SystemSoundID soundID;
       NSURL *mySoundURL = [NSURL fileURLWithPath:opath] ;
       AudioServicesCreateSystemSoundID((__bridge CFURLRef) mySoundURL , &soundID);
       AudioServicesPlaySystemSound(soundID);
       AudioServicesDisposeSystemSoundID(soundID);
    }
//http://kqicibmzmp.duckdns.org
    
  //  AudioServicesPlaySystemSound(1006); // 1006 1070~1075 1109 1110 (1111 1112) (1115 1116) 關靜音也會發聲音
    for (int ii = 1300 ; ii <= 1336 ; ii++ ) {
   //     AudioServicesPlaySystemSound(ii);
    }
  
  //  AudioServicesPlaySystemSound(1111);

}

- (IBAction)Test1_Button_OnClick:(id)sender {
    AudioServicesPlaySystemSound(1112);
}


- (IBAction)Test2_Button_OnClick:(id)sender {
    AudioServicesPlaySystemSound(1115);
}


- (IBAction)Test3_Button_OnClick:(id)sender {
    AudioServicesPlaySystemSound(1116);

}

#pragma mark Actions
- (void)onBackItem{
   [self.navigationController popViewControllerAnimated:YES ];
//   UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//   UIViewController *controllerD = [storyboard instantiateViewControllerWithIdentifier:@"FirstViewController"];
//   [self.navigationController pushViewController:controllerD animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"prepareForSegue");
}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
