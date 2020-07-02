@interface auroreMusicTableViewController : UITableViewController
@property (nonatomic,retain) NSString *link;
@property (nonatomic,retain) NSNumber *shuffle;
@property (nonatomic,retain) NSNumber *volumeMax;
@property (nonatomic,retain) NSNumber *volumeTime;
@property (nonatomic,retain) NSString *bluetooth;
@property (nonatomic,retain) NSString *airplay;
- (id)initWithSettings:(NSDictionary *)settings;
@end