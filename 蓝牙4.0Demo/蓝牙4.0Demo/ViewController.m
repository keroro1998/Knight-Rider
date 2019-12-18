#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDataSource,UITableViewDelegate>

/// Central manager-> Scan for management device-Connect
@property (nonatomic, strong) CBCentralManager *centralManager;
// 存储的设备 Storage device
@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) NSMutableArray *peripheralsname;
// 扫描到的设备 Scanned devices
@property (nonatomic, strong) CBPeripheral *cbPeripheral;
@property (nonatomic, strong) CBCharacteristic *wcharacteristic;
//文本 Text
@property (weak, nonatomic) IBOutlet UITextView *peripheralText;
//蓝牙状态 Bluetooth static
@property (nonatomic, assign) CBManagerState peripheralState;
@property (nonatomic, strong) NSMutableArray *arrayDS;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

// 通知服务 notify service
static NSString * const null;
static NSString * const kNotifyServerUUID = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
// 写服务 write service
static NSString * const kWriteServerUUID = @"FFFFF";
// 通知特征值 notify characteristic
static NSString * const kNotifyCharacteristicUUID = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
// 写特征值 write characteristic
static NSString * const kWriteCharacteristicUUID = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E";

@implementation ViewController
//Device storage array
- (NSMutableArray *)peripherals
{
    if (!_peripherals) {
        _peripherals =  [[NSMutableArray alloc] init];
    }
    return _peripherals;
}
//Array of device names
- (NSMutableArray *)peripheralsname
{
    if (!_peripheralsname) {
        _peripheralsname =  [[NSMutableArray alloc] init];
    }
    return _peripheralsname;
}
//Central Manager
- (CBCentralManager *)centralManager
{
    if (!_centralManager)
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _centralManager;
}

// 扫描设备按钮 scan the devices button
- (IBAction)scanForPeripherals
{
    [self.centralManager stopScan];
    NSLog(@"Scanning device");
    [self showMessage:@"Scanning device"];
    if (self.peripheralState ==  CBManagerStatePoweredOn)
    {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

// 停止扫描设备 stop scanning the devices button
- (IBAction)StopScanningPeripherals
{
   [self setupDatas2];//Update connectable device
   [self.tableView reloadData];//Show connectable devices
   [self.centralManager stopScan];
   /*  if (self.cbPeripheral != nil)
     {   [self showMessage:@"Start connecting"];
        NSLog(@"Connecting device");
        [self showMessage:@"Connecting device"];
        [self.centralManager connectPeripheral:self.cbPeripheral options:nil];
                        
        for (int i = 0; i < [self.peripherals count]; i++){
            
                      [self showMessage:[NSString stringWithFormat:@"find device,device name:%@", [self.peripheralsname objectAtIndex:i]]];
                      }
       
    }
    else
    {
        [self showMessage:@"No device to connect"];
    }
    */
}

// 清空设备 Empty the devices button
- (IBAction)clearPeripherals
{
    NSLog(@"Empty device");
    [self.centralManager stopScan];
    [self.peripherals removeAllObjects];//remove all the objects
    [self.peripheralsname removeAllObjects];//remove all the names of objects
    [self setupDatas];//Initialize connectable devices
    [self.tableView reloadData];//Show connectable devices
    self.peripheralText.text = @"";
    [self showMessage:@"Empty device"];
    
    if (self.cbPeripheral != nil)
    {
        // 取消连接 Cancel connection
        NSLog(@"Cancel connection");
        [self showMessage:@"Cancel connection"];
        [self.centralManager cancelPeripheralConnection:self.cbPeripheral];
    }
}

- (void)viewDidLoad {//Loading views
    [super viewDidLoad];
    [self centralManager];
    [self setupDatas];//Setup Datas
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
// 状态更新时调用 This function is called when the status is updated
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:{ //unknown state
            NSLog(@"为知状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateResetting:
        {
            NSLog(@"重置状态");//resetting state
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnsupported:
        {
            NSLog(@"不支持的状态");//unsupported state
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnauthorized:
        {
            NSLog(@"未授权的状态");//unauthorized state
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@"关闭状态");//powere off state
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"开启状态－可用状态");//powere on state
            self.peripheralState = central.state;
            NSLog(@"%ld",(long)self.peripheralState);
        }
            break;
        default:
            break;
    }
}
/**
 扫描到设备 Diacover divices
 
 @param central 中心管理者 Central manager
 @param peripheral 扫描到的设备 Scanned devices
 @param advertisementData 广告信息 Broadcast information
 @param RSSI 信号强度 Signal strength
 */
//This function is called when a device is found
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
   advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{    if (![self.peripherals containsObject:peripheral])//If this device is not in the previously saved device array
    {
    if(peripheral.name != nil){
    [self showMessage:[NSString stringWithFormat:@"find device,device name:%@",peripheral.name]];
        //Save device to array
        [self.peripherals addObject:peripheral];
       //Save the name of device to array
        [self.peripheralsname addObject:peripheral.name];
        NSLog(@"%@",peripheral);
    }
}
}

/**
 连接失败 Fail to connect device
 
 @param central 中心管理者 Central manager
 @param peripheral 连接失败的设备 Device that failed to connect
 @param error 错误信息 Error information
 */
//
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self showMessage:@"connect fail"];

    [self.centralManager connectPeripheral:peripheral options:nil];
    
}

/**
 连接断开 Disconnect device
 
 @param central 中心管理者 Central manager
 @param peripheral 连接断开的设备 Disconnect device
 @param error 错误信息 Error information
 */

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self showMessage:@"Disconnect"];
  
        [self.centralManager connectPeripheral:peripheral options:nil];
   
}

/**
 连接成功 Connection succeeded
 
 @param central 中心管理者 Central manager
 @param peripheral 连接成功的设备 Connected device
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{//
    NSLog(@"Connecting device:%@success",peripheral.name);
    
//    self.peripheralText.text = [NSString stringWithFormat:@"连接设备:%@成功",peripheral.name];
    [self showMessage:[NSString stringWithFormat:@"Connecting device:%@ success",peripheral.name]];
    // 设置设备的代理 Setting the device's proxy
    peripheral.delegate = self;
    // services:传入nil  代表扫描所有服务 Incoming nil scans all services
    [peripheral discoverServices:nil];
}

/**
 扫描到服务 Discover Services
 
 @param peripheral 服务对应的设备 Service corresponding device
 @param error 扫描错误信息 Scanning for error messages
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // 遍历所有的服务 Iterating through all services
    int flag=0;
    for (CBService *service in peripheral.services)
    {
        NSLog(@"service:%@",service.UUID.UUIDString);
        // 获取对应的服务 Get the corresponding service
        if ([service.UUID.UUIDString isEqualToString:kWriteServerUUID] || [service.UUID.UUIDString isEqualToString:kNotifyServerUUID])
        {
            [self showMessage:@"Find services"];
            // 根据服务去扫描特征 Scan characteristic based on service
            [peripheral discoverCharacteristics:nil forService:service];
            flag=1;
        }
        
    }
    //if flag=0, the required service is not found, then disconnect
    if(flag ==0){
    [self showMessage:@"Find no service"];
    [self.centralManager cancelPeripheralConnection:self.cbPeripheral];
    [self showMessage:@"cancel connect"];
    }
}

/**
扫描到对应的特征 Scan to the corresponding characteristic

@param peripheral 设备 device
@param service 特征对应的服务 Charateristic corresponding service
@param error 错误信息 Error information
*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // 遍历所有的特征 Iterate over all characteristic
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"Characteristic:%@",characteristic.UUID.UUIDString);
        //if find the characteristic that we want
        if ([characteristic.UUID.UUIDString isEqualToString:kWriteCharacteristicUUID])
        {
            // 写入数据 Show in text box:Find Write Characteristic
            [self showMessage:@"Find Write Characteristic"];
            self.wcharacteristic=characteristic;
        }
        //if find the notify charcteristic that we want
        if ([characteristic.UUID.UUIDString isEqualToString:kNotifyCharacteristicUUID])
         {
             //Show in text box:set notify success
             [self showMessage:@"set notify success"];
             //set notify
             [peripheral setNotifyValue:YES forCharacteristic:characteristic];
         }
    }
}
//MOVE button, after pressing, will send data to the microcontroller
- (IBAction)Move{
    //those datas are These data are meaningless, just for testing
     Byte byte[] = {0x3c, 0x3c, 0x3c, 0x3d,
         0x3d,};
     NSData *data = [NSData dataWithBytes:byte length:6];
    [self.cbPeripheral writeValue:data forCharacteristic:self.wcharacteristic type:CBCharacteristicWriteWithResponse];
     [self showMessage:@"MOVE"];
}


/**
 After the characteristic data is updated
 根据特征读到数据 Reading data based on characteristics
 
 @param peripheral 读取到数据对应的设备 读取到数据对应的设备
 @param characteristic 特征
 @param error 错误信息 Error information
 */
- (void)peripheral:(CBPeripheral *)peripheral  didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
   
   if ([characteristic.UUID.UUIDString isEqualToString:kNotifyCharacteristicUUID])
      {
        NSData *data = characteristic.value;
        NSLog(@"%@",data);
      [self showMessage:[NSString stringWithFormat:@"%@",data]];
      }

}
//Functions displayed in text boxes
- (void)showMessage:(NSString *)message
{
    self.peripheralText.text = [self.peripheralText.text stringByAppendingFormat:@"%@\n",message];
    [self.peripheralText scrollRectToVisible:CGRectMake(0, self.peripheralText.contentSize.height -15, self.peripheralText.contentSize.width, 10) animated:YES];
}


//Receive Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Initialize views
- (void)setupDatas {
    self.arrayDS = [[NSMutableArray alloc] init];
}
//Update views
- (void)setupDatas2 {
    self.arrayDS=self.peripheralsname;
    
}


/**
 *  UITableViewDataSource协议中的所有方法,用来对表格视图的样式进行设置(比如说显示的分区个数、每个分区中单元格个数、单元格中显示内容、分区头标题、分区未标题、分区的View)
    All methods in the UITableViewDataSource protocol are used to set the style of the table view (such as the number of partitions displayed, the number of cells in each partition, the content displayed in the cell, the header of the partition header, the untitled partition, the View)
 *
 */
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/**
 *  设置每个分区显示的行数
 *  Set the number of rows displayed per partition
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

        return [self.arrayDS count];
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ///<1.>设置标识符 Set identifier
    static NSString * str = @"cellStr";
    ///<2.>复用机制:如果一个页面显示7个cell，系统则会创建8个cell,当用户向下滑动到第8个cell时，第一个cell进入复用池等待复用。
    ///Reuse mechanism: If there are 7 cells displayed on a page, the system will create 8 cells. When the user slides down to the 8th cell, the first cell enters the reuse pool and waits for reuse.
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    ///<3.>新建cell New cell
    if (cell == nil) {
        //副标题样式 Subtitle style
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
    }
    ///<4.>设置单元格上显示的文字信息 Set the text information displayed on the cell
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.arrayDS objectAtIndex:indexPath.row]];
   
    
    return cell;
}

/**
 *  由于表格的样式设置成plain样式,但是不能说明当前的表格不显示分区
 *  Because the style of the table is set to plain style, it cannot explain that the current table does not display partitions
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

        return @"devices";

}

/**
 *  设置单元格的高度
 *  单元格默认高度60像素
 *  Set the height of the cell
    Cell default height 60 pixels
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

/**
 *  UITableViewDelegate协议中所有方法，用来对单元格自身进行操作(比如单元格的删除、添加、移动...)
 *  All methods in the UITableViewDelegate protocol are used to perform operations on the cell itself (such as delete, add, move ...)
 */
#pragma UITableViewDelegate

/**
 *  点击单元格触发该方法
 *  Clicking on the cell triggers the method
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.cbPeripheral =  [self.peripherals objectAtIndex:indexPath.row];
    [self showMessage:@"Connecting device"];
    [self.centralManager connectPeripheral:self.cbPeripheral options:nil];
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *selectCellStr = [NSString stringWithFormat:@"find device,device name:%@", [self.peripherals objectAtIndex:indexPath.row]];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:selectCellStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}
//Refresh the data again
- (void)reloadData
{
    [self.tableView reloadData];

 
}

@end
