//
//  TTHistoryViewController.m
//  TruckRoute
//
//  Created by admin on 10/8/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import "TTHistoryViewController.h"
#import "TTFindMenuViewController.h"
#import "TTCellCursorView.h"

@interface TTHistoryViewController ()
{
    NSMutableDictionary *tempDict;
//    NSArray * historySearchResults;
    NSMutableDictionary * searchResultsTempDict;

}

@property (retain, nonatomic) NSMutableArray * historySearchResults;
@property (retain, nonatomic) NSIndexPath *indexPathOfSearchTableSelected;

@end


@implementation TTHistoryViewController
@synthesize route_request;
@synthesize isDestination;
@synthesize isEditing;
@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //[self getCurrentOrientation];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
   // [self getCurrentOrientation];
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.isVisible = NO;
    if (!_isNotificationOn) {
        [(TTHistoryViewController *)_superViewController  setIsVisible:NO];
    }
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isShowingLandscapeView = NO;
    
    if (_isNotificationOn) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        //  [self orientationChanged:nil];
    }
    containView.layer.cornerRadius=7;
    containView.layer.borderColor=[UIColor darkGrayColor].CGColor;
    containView.layer.borderWidth=0.5;
    
    // [self getCurrentOrientation];
    // Do any additional setup after loading the view.
    idxSelected = -1;
    isEditing = NO;
    //load history
    NSArray *arrayHistory = nil;
    NSUserDefaults *dataDefault = [NSUserDefaults standardUserDefaults];
    arrayHistory = [dataDefault arrayForKey:@"History"];
    resultArray = [[NSMutableArray alloc]init];
    favoriteArray = [[NSMutableArray alloc]init];
    for(id object in arrayHistory)
        [resultArray addObject:object];
    
    favoriteArray = [[self sortArrayByFavorite:resultArray] mutableCopy];
    self.historySearchResults = [NSMutableArray array];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setBtnEdit:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    self.searchController = nil;
    self.searchController.delegate = nil;
    self.searchController.searchResultsDelegate = nil;
    self.searchController.searchResultsDataSource = nil;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isVisible=YES;
    if (_isNotificationOn) {
        [self orientationChanged:nil];
    }
    else{
        [(TTHistoryViewController *)_superViewController  setIsVisible:YES];
        [(TTHistoryViewController *)_superViewController  viewDidAppear:YES];
    }

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
//    self.isVisible=YES;
//    if (_isNotificationOn) {
//        [self orientationChanged:nil];
//    }
//    else{
//        [(TTHistoryViewController *)_superViewController  setIsVisible:YES];
//    }
    NSUserDefaults *dataDefault = [NSUserDefaults standardUserDefaults];
    if ([dataDefault boolForKey:@"isSwitchEnabled"]) {
        [_sortSwitch setOn:YES];
    }
    else {
        [_sortSwitch setOn:NO];
    }
}

-(void)dealloc
{
    [resultArray release];
    [favoriteArray release];
    [_tableView release];
    [_btnEdit release];
    [_tableView release];
    [_sortSwitch release];
    self.searchDisplayController.delegate = nil;
    self.searchDisplayController.searchResultsDelegate = nil;
    self.searchDisplayController.searchResultsDataSource = nil;
    [super dealloc];
}
 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        //if (IS_IPAD) {
            [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
//        }else{
//            [self dismissViewControllerAnimated:YES completion:nil];
//            [self.delegate backButtonClick:self];
//
//        }
    }
}

- (IBAction)ok:(id)sender {
    if (idxSelected == -1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"please select an address"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    //update route_request
    [self updateAddress];

    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
//        [self dismissViewControllerAnimated:NO completion:nil];
//        [self.delegate backButtonClick:self];
    }
}

- (IBAction)edit:(id)sender
{
    if (isEditing) {
        isEditing = NO;
        [_tableView setEditing:NO animated:YES];
        [_btnEdit setTitle:@"Edit" forState:UIControlStateNormal];
    }else {
        isEditing = YES;
        [_tableView setEditing:YES animated:YES];
        [_btnEdit setTitle:@"Done" forState:UIControlStateNormal];
    }
//    [_tableView reloadData];
}

-(void)updateAddress
{
    /*
    // Favorite array check
    if ([_sortSwitch isEnabled]) 
    {
        NSDictionary *dict = [[NSDictionary alloc]init];
        dict = [favoriteArray objectAtIndex:idxSelected];
        idxSelected = [resultArray indexOfObjectIdenticalTo:dict];
    } */
    
    if ([_sortSwitch isOn]) {
        
        //update route_request
        tempDict = [[favoriteArray objectAtIndex:idxSelected] mutableCopy];
        NSString *string = [tempDict valueForKey:@"LocationString"];
        NSArray *str_array = [string componentsSeparatedByString:@"\n"];
        NSArray *coord = [[str_array objectAtIndex:1] componentsSeparatedByString:@","];
        CLLocationCoordinate2D loc;
        loc.latitude = [[coord objectAtIndex:0] doubleValue];
        loc.longitude = [[coord objectAtIndex:1] doubleValue];
        if (route_request) {
            if (isDestination) {
                //update end address and end location
                [route_request setEnd_address:[str_array objectAtIndex:0]];
                [route_request setEnd_location:loc];
            }else {
                //update start address and start location
                [route_request setStart_address:[str_array objectAtIndex:0]];
                [route_request setStart_location:loc];
            }
        }else {//from find poi vc
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"POI_SEARCH_ADDRESS"];
            [userDefaults removeObjectForKey:@"POI_SEARCH_LOCATION_LAT"];
            [userDefaults removeObjectForKey:@"POI_SEARCH_LOCATION_LON"];
            [userDefaults setObject:[NSString stringWithString:[str_array objectAtIndex:0]] forKey:@"POI_SEARCH_ADDRESS"];
            [userDefaults setDouble:loc.latitude forKey:@"POI_SEARCH_LOCATION_LAT"];
            [userDefaults setDouble:loc.longitude forKey:@"POI_SEARCH_LOCATION_LON"];
            //[(TTFindMenuViewController *)self.presentingViewController updateNewAddress];
            if (_isNotificationOn) {
                [(TTFindMenuViewController *)self.presentingViewController updateNewAddress];
            }
            else{
                [(TTFindMenuViewController *)_pViewController updateNewAddress];
            }
        }
    }
    
    else {
        
        //update route_request
        tempDict = [[resultArray objectAtIndex:idxSelected] mutableCopy];
        NSString *string = [tempDict valueForKey:@"LocationString"];
        NSArray *str_array = [string componentsSeparatedByString:@"\n"];
        NSArray *coord = [[str_array objectAtIndex:1] componentsSeparatedByString:@","];
        CLLocationCoordinate2D loc;
        loc.latitude = [[coord objectAtIndex:0] doubleValue];
        loc.longitude = [[coord objectAtIndex:1] doubleValue];
        if (route_request) {
            if (isDestination) {
                //update end address and end location
                [route_request setEnd_address:[str_array objectAtIndex:0]];
                [route_request setEnd_location:loc];
            }else {
                //update start address and start location
                [route_request setStart_address:[str_array objectAtIndex:0]];
                [route_request setStart_location:loc];
            }
        }else {//from find poi vc
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"POI_SEARCH_ADDRESS"];
            [userDefaults removeObjectForKey:@"POI_SEARCH_LOCATION_LAT"];
            [userDefaults removeObjectForKey:@"POI_SEARCH_LOCATION_LON"];
            [userDefaults setObject:[NSString stringWithString:[str_array objectAtIndex:0]] forKey:@"POI_SEARCH_ADDRESS"];
            [userDefaults setDouble:loc.latitude forKey:@"POI_SEARCH_LOCATION_LAT"];
            [userDefaults setDouble:loc.longitude forKey:@"POI_SEARCH_LOCATION_LON"];
            if (_isNotificationOn) {
                [(TTFindMenuViewController *)self.presentingViewController updateNewAddress];
            }
            else{
                [(TTFindMenuViewController *)_pViewController updateNewAddress];
                
            }
        }
    }
}

// Use this method when creating route from filtered search result table.
-(void)updateAddressFromFilteredSearch
{
    /*
     // Favorite array check
     if ([_sortSwitch isEnabled])
     {
     NSDictionary *dict = [[NSDictionary alloc]init];
     dict = [favoriteArray objectAtIndex:idxSelected];
     idxSelected = [resultArray indexOfObjectIdenticalTo:dict];
     } */
    
    if ([_sortSwitch isOn]) {
        
        //update route_request
        tempDict = [[self.historySearchResults objectAtIndex:idxSelected] mutableCopy];
        NSString *string = [tempDict valueForKey:@"LocationString"];
        NSArray *str_array = [string componentsSeparatedByString:@"\n"];
        NSArray *coord = [[str_array objectAtIndex:1] componentsSeparatedByString:@","];
        CLLocationCoordinate2D loc;
        loc.latitude = [[coord objectAtIndex:0] doubleValue];
        loc.longitude = [[coord objectAtIndex:1] doubleValue];
        if (route_request) {
            if (isDestination) {
                //update end address and end location
                [route_request setEnd_address:[str_array objectAtIndex:0]];
                [route_request setEnd_location:loc];
            }else {
                //update start address and start location
                [route_request setStart_address:[str_array objectAtIndex:0]];
                [route_request setStart_location:loc];
            }
        }else {//from find poi vc
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"POI_SEARCH_ADDRESS"];
            [userDefaults removeObjectForKey:@"POI_SEARCH_LOCATION_LAT"];
            [userDefaults removeObjectForKey:@"POI_SEARCH_LOCATION_LON"];
            [userDefaults setObject:[NSString stringWithString:[str_array objectAtIndex:0]] forKey:@"POI_SEARCH_ADDRESS"];
            [userDefaults setDouble:loc.latitude forKey:@"POI_SEARCH_LOCATION_LAT"];
            [userDefaults setDouble:loc.longitude forKey:@"POI_SEARCH_LOCATION_LON"];
            //[(TTFindMenuViewController *)self.presentingViewController updateNewAddress];
            if (_isNotificationOn) {
                [(TTFindMenuViewController *)self.presentingViewController updateNewAddress];
            }
            else{
                [(TTFindMenuViewController *)_pViewController updateNewAddress];
            }
        }
    }
    
    else {
        
        //update route_request
        tempDict = [[self.historySearchResults objectAtIndex:idxSelected] mutableCopy];
        NSString *string = [tempDict valueForKey:@"LocationString"];
        NSArray *str_array = [string componentsSeparatedByString:@"\n"];
        NSArray *coord = [[str_array objectAtIndex:1] componentsSeparatedByString:@","];
        CLLocationCoordinate2D loc;
        loc.latitude = [[coord objectAtIndex:0] doubleValue];
        loc.longitude = [[coord objectAtIndex:1] doubleValue];
        if (route_request) {
            if (isDestination) {
                //update end address and end location
                [route_request setEnd_address:[str_array objectAtIndex:0]];
                [route_request setEnd_location:loc];
            }else {
                //update start address and start location
                [route_request setStart_address:[str_array objectAtIndex:0]];
                [route_request setStart_location:loc];
            }
        }else {//from find poi vc
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"POI_SEARCH_ADDRESS"];
            [userDefaults removeObjectForKey:@"POI_SEARCH_LOCATION_LAT"];
            [userDefaults removeObjectForKey:@"POI_SEARCH_LOCATION_LON"];
            [userDefaults setObject:[NSString stringWithString:[str_array objectAtIndex:0]] forKey:@"POI_SEARCH_ADDRESS"];
            [userDefaults setDouble:loc.latitude forKey:@"POI_SEARCH_LOCATION_LAT"];
            [userDefaults setDouble:loc.longitude forKey:@"POI_SEARCH_LOCATION_LON"];
            if (_isNotificationOn) {
                [(TTFindMenuViewController *)self.presentingViewController updateNewAddress];
            }
            else{
                [(TTFindMenuViewController *)_pViewController updateNewAddress];
                
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchController.searchResultsTableView) {
        return self.historySearchResults.count;
    }
    else{
        
        //#warning Incomplete method implementation.
        // Return the number of rows in the section.
        return resultArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    
    if ([_sortSwitch isOn]) {
        // Configure the cell...
        tempDict = [[favoriteArray objectAtIndex:[indexPath row]] mutableCopy];
        NSString *string = [tempDict valueForKey:@"LocationString"];
        NSArray *str_array = [string componentsSeparatedByString:@"\n"];
       
        
        
        if (tableView == self.searchController.searchResultsTableView) {
            
            searchResultsTempDict = [[self.historySearchResults objectAtIndex:[indexPath row]] mutableCopy];
            NSString *filteredString = [searchResultsTempDict valueForKey:@"LocationString"];
            NSArray *filteredStrArray = [filteredString componentsSeparatedByString:@"\n"];
            [cell.textLabel setText:[filteredStrArray objectAtIndex:0]];
            [cell.detailTextLabel setText:[filteredStrArray objectAtIndex:1]];
            
            if ([[searchResultsTempDict valueForKey:@"LocationStatus"] intValue] == 1) {
                [cell.imageView setImage:[UIImage imageNamed:@"fav.png"]];
            }
            else if ([[searchResultsTempDict valueForKey:@"LocationStatus"] intValue] == 0) {
                [cell.imageView setImage:nil];
            }
        }
        else {
        [cell.textLabel setText:[str_array objectAtIndex:0]];
        [cell.detailTextLabel setText:[str_array objectAtIndex:1]];
            
            if ([[tempDict valueForKey:@"LocationStatus"] intValue] == 1) {
                [cell.imageView setImage:[UIImage imageNamed:@"fav.png"]];
            }
            else if ([[tempDict valueForKey:@"LocationStatus"] intValue] == 0) {
                [cell.imageView setImage:nil];
            }

        }
        
    }
    else {
        // Configure the cell...
        tempDict = [[resultArray objectAtIndex:[indexPath row]] mutableCopy];
        NSString *string = [tempDict valueForKey:@"LocationString"];
        NSArray *str_array = [string componentsSeparatedByString:@"\n"];
        
        if (tableView == self.searchController.searchResultsTableView) {
            searchResultsTempDict = [[self.historySearchResults objectAtIndex:[indexPath row]] mutableCopy];
            NSString *filteredString = [searchResultsTempDict valueForKey:@"LocationString"];
            NSArray *filteredStrArray = [filteredString componentsSeparatedByString:@"\n"];
            [cell.textLabel setText:[filteredStrArray objectAtIndex:0]];
            [cell.detailTextLabel setText:[filteredStrArray objectAtIndex:1]];
            
            if ([[searchResultsTempDict valueForKey:@"LocationStatus"] intValue] == 1) {
                [cell.imageView setImage:[UIImage imageNamed:@"fav.png"]];
            }
            else if ([[searchResultsTempDict valueForKey:@"LocationStatus"] intValue] == 0) {
                [cell.imageView setImage:nil];
            }

        }
        else {
            [cell.textLabel setText:[str_array objectAtIndex:0]];
            [cell.detailTextLabel setText:[str_array objectAtIndex:1]];
            
            if ([[tempDict valueForKey:@"LocationStatus"] intValue] == 1) {
                [cell.imageView setImage:[UIImage imageNamed:@"fav.png"]];
            }
            else if ([[tempDict valueForKey:@"LocationStatus"] intValue] == 0) {
                [cell.imageView setImage:nil];
            }
        }
    }
    return cell;

}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This code is run if the tableView is search results table view. The only difference in this code and the code in else part is - use self.historySearchResults instead of resultsArray. Also the alert tag is made 9001.
    if (tableView == self.searchController.searchResultsTableView) {
        if ([_sortSwitch isOn]) {
            
            if (tableView.editing) {
                tempDict = [[self.historySearchResults objectAtIndex:[indexPath row]] mutableCopy];
                NSString *string = [tempDict valueForKey:@"LocationString"];
                NSArray *str_array = [string componentsSeparatedByString:@","];
                NSString *msgstr=[NSString stringWithFormat:@"\n %@",[str_array objectAtIndex:0]];
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Name this point" message:msgstr delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
                alertView.tag=indexPath.row;
                [alertView show];
            }
            else {
                idxSelected = [indexPath row];
                tempDict = [[self.historySearchResults objectAtIndex:[indexPath row]] mutableCopy];
                NSNumber *locationStatus = [tempDict valueForKey:@"LocationStatus"];
                NSString *alertString = @"";
                NSString *optionString = @"";
                if ([locationStatus intValue] == 0) {
                    alertString = @"Would you like to add it to favorite?";
                    optionString = @"Add to favorite";
                }
                else if ([locationStatus intValue] == 1) {
                    alertString = @"Would you like to remove it from favorite?";
                    optionString = @"Remove from favorite";
                }
                if (isDestination) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:optionString, @"Create Route",nil];
                    alert.tag = 9001;
                    [alert show];
                }
                else if (!isDestination) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:alertString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:optionString,nil];
                    alert.tag = 9001;
                    [alert show];
                }
                
            }
        }
        
        else {
            
            if (tableView.editing) {
                tempDict = [[self.historySearchResults objectAtIndex:[indexPath row]] mutableCopy];
                NSString *string = [tempDict valueForKey:@"LocationString"];
                //NSArray *arr=[string componentsSeparatedByString:@"\n"];
                //if (arr.count==3)
                {
                    NSArray *str_array = [string componentsSeparatedByString:@","];
                    NSString *msgstr=[NSString stringWithFormat:@"\n %@",[str_array objectAtIndex:0]];
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Name this point" message:msgstr delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                    alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
                    //[[alertView textFieldAtIndex:0] setText:[str_array objectAtIndex:0]];
                    alertView.tag=indexPath.row;
                    [alertView show];
                }
                
            }
            else {
                
                idxSelected = [indexPath row];
                tempDict = [[self.historySearchResults objectAtIndex:[indexPath row]] mutableCopy];
                NSNumber *locationStatus = [tempDict valueForKey:@"LocationStatus"];
                NSString *alertString = @"";
                NSString *optionString = @"";
                if ([locationStatus intValue] == 0) {
                    alertString = @"Would you like to add it to favorite?";
                    optionString = @"Add to favorite";
                }
                else if ([locationStatus intValue] == 1) {
                    alertString = @"Would you like to remove it from favorite?";
                    optionString = @"Remove from favorite";
                }
                if (isDestination) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:optionString, @"Create Route", nil];
                    alert.tag = 9001;
                    [alert show];
                }
                else if (!isDestination) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:alertString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:optionString, nil];
                    alert.tag = 9001;
                    [alert show];
                }
            }
    
        }
        self.indexPathOfSearchTableSelected = indexPath;
    }
    
    
    else {
        
        
        if ([_sortSwitch isOn]) {
            
            if (tableView.editing) {
                tempDict = [[favoriteArray objectAtIndex:[indexPath row]] mutableCopy];
                NSString *string = [tempDict valueForKey:@"LocationString"];
                NSArray *str_array = [string componentsSeparatedByString:@","];
                NSString *msgstr=[NSString stringWithFormat:@"\n %@",[str_array objectAtIndex:0]];
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Name this point" message:msgstr delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
                alertView.tag=indexPath.row;
                [alertView show];
                
                
                
            }
            else {
                
                idxSelected = [indexPath row];
                tempDict = [[favoriteArray objectAtIndex:[indexPath row]] mutableCopy];
                NSNumber *locationStatus = [tempDict valueForKey:@"LocationStatus"];
                NSString *alertString = @"";
                NSString *optionString = @"";
                if ([locationStatus intValue] == 0) {
                    alertString = @"Would you like to add it to favorite?";
                    optionString = @"Add to favorite";
                }
                else if ([locationStatus intValue] == 1) {
                    alertString = @"Would you like to remove it from favorite?";
                    optionString = @"Remove from favorite";
                }
                if (isDestination) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:optionString, @"Create Route",nil];
                    alert.tag = 9000;
                    [alert show];
                }
                else if (!isDestination) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:alertString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:optionString,nil];
                    alert.tag = 9000;
                    [alert show];
                }
                
            }
        }
        
        else {
            
            if (tableView.editing) {
                tempDict = [[resultArray objectAtIndex:[indexPath row]] mutableCopy];
                NSString *string = [tempDict valueForKey:@"LocationString"];
                //NSArray *arr=[string componentsSeparatedByString:@"\n"];
                //if (arr.count==3)
                {
                    NSArray *str_array = [string componentsSeparatedByString:@","];
                    NSString *msgstr=[NSString stringWithFormat:@"\n %@",[str_array objectAtIndex:0]];
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Name this point" message:msgstr delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                    alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
                    //[[alertView textFieldAtIndex:0] setText:[str_array objectAtIndex:0]];
                    alertView.tag=indexPath.row;
                    [alertView show];
                }
                
            }
            else {
                
                idxSelected = [indexPath row];
                tempDict = [[resultArray objectAtIndex:[indexPath row]] mutableCopy];
                NSNumber *locationStatus = [tempDict valueForKey:@"LocationStatus"];
                NSString *alertString = @"";
                NSString *optionString = @"";
                if ([locationStatus intValue] == 0) {
                    alertString = @"Would you like to add it to favorite?";
                    optionString = @"Add to favorite";
                }
                else if ([locationStatus intValue] == 1) {
                    alertString = @"Would you like to remove it from favorite?";
                    optionString = @"Remove from favorite";
                }
                if (isDestination) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:optionString, @"Create Route", nil];
                    alert.tag = 9000;
                    [alert show];
                }
                else if (!isDestination) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:alertString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:optionString, nil];
                    alert.tag = 9000;
                    [alert show];
                }
            }
        }
    }
    
    //    if ([_sortSwitch isOn]) {
    //
    //        if (tableView.editing) {
    //            tempDict = [[favoriteArray objectAtIndex:[indexPath row]] mutableCopy];
    //            NSString *string = [tempDict valueForKey:@"LocationString"];
    //            NSArray *str_array = [string componentsSeparatedByString:@","];
    //            NSString *msgstr=[NSString stringWithFormat:@"\n %@",[str_array objectAtIndex:0]];
    //            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Name this point" message:msgstr delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    //            alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
    //            alertView.tag=indexPath.row;
    //            [alertView show];
    //
    //
    //
    //        }
    //        else {
    //
    //            idxSelected = [indexPath row];
    //            tempDict = [[favoriteArray objectAtIndex:[indexPath row]] mutableCopy];
    //            NSNumber *locationStatus = [tempDict valueForKey:@"LocationStatus"];
    //            NSString *alertString = @"";
    //            NSString *optionString = @"";
    //            if ([locationStatus intValue] == 0) {
    //                alertString = @"Would you like to add it to favorite?";
    //                optionString = @"Add to favorite";
    //            }
    //            else if ([locationStatus intValue] == 1) {
    //                alertString = @"Would you like to remove it from favorite?";
    //                optionString = @"Remove from favorite";
    //            }
    //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:alertString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:optionString, nil];
    //            alert.tag = 9000;
    //            [alert show];
    //        }
    //    }
    //
    //    else {
    //
    //        if (tableView.editing) {
    //            tempDict = [[resultArray objectAtIndex:[indexPath row]] mutableCopy];
    //            NSString *string = [tempDict valueForKey:@"LocationString"];
    //            //NSArray *arr=[string componentsSeparatedByString:@"\n"];
    //            //if (arr.count==3)
    //            {
    //                NSArray *str_array = [string componentsSeparatedByString:@","];
    //                NSString *msgstr=[NSString stringWithFormat:@"\n %@",[str_array objectAtIndex:0]];
    //                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Name this point" message:msgstr delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    //                alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
    //                //[[alertView textFieldAtIndex:0] setText:[str_array objectAtIndex:0]];
    //                alertView.tag=indexPath.row;
    //                [alertView show];
    //            }
    //
    //        }
    //        else {
    //
    //            idxSelected = [indexPath row];
    //            tempDict = [[resultArray objectAtIndex:[indexPath row]] mutableCopy];
    //            NSNumber *locationStatus = [tempDict valueForKey:@"LocationStatus"];
    //            NSString *alertString = @"";
    //            NSString *optionString = @"";
    //            if ([locationStatus intValue] == 0) {
    //                alertString = @"Would you like to add it to favorite?";
    //                optionString = @"Add to favorite";
    //            }
    //            else if ([locationStatus intValue] == 1) {
    //                alertString = @"Would you like to remove it from favorite?";
    //                optionString = @"Remove from favorite";
    //            }
    //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:alertString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:optionString, nil];
    //            alert.tag = 9000;
    //            [alert show];
    //        }
    //    }
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_sortSwitch isOn]) {
        [_tableView beginUpdates];
        tempDict = [[favoriteArray objectAtIndex:indexPath.row] mutableCopy];
        [favoriteArray removeObjectAtIndex:indexPath.row];
        [resultArray removeObject:tempDict];
        NSArray *array = [[[NSArray alloc]initWithObjects:indexPath, nil]autorelease];
        //NSArray *array = [[NSArray alloc]initWithObjects:indexPath, nil];
        [_tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
        [_tableView endUpdates];
        //update history
        [self updateHistory];
        idxSelected = -1;
    }
    
    else {
        
        [_tableView beginUpdates];
        tempDict = [[resultArray objectAtIndex:indexPath.row] mutableCopy];
        [resultArray removeObjectAtIndex:indexPath.row];
        [favoriteArray removeObject:tempDict];
        NSArray *array = [[[NSArray alloc]initWithObjects:indexPath, nil]autorelease];
        //NSArray *array = [[NSArray alloc]initWithObjects:indexPath, nil];
        [_tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
        [_tableView endUpdates];
        //update history
        [self updateHistory];
        idxSelected = -1;
    }
}

-(void)alertView:(UIAlertView *)alertView11 clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView11.tag == 9000) {
        
        if (buttonIndex ==1) {
            
            if ([_sortSwitch isOn]) {
                
                tempDict = [[favoriteArray objectAtIndex:idxSelected] mutableCopy];
                int indx = [resultArray indexOfObject:tempDict];
                NSNumber *locationStatus = [tempDict valueForKey:@"LocationStatus"];
                if ([locationStatus intValue] == 0) {
                    [tempDict setValue:[NSNumber numberWithInt:1] forKey:@"LocationStatus"];
                }
                else if ([locationStatus intValue] == 1) {
                    [tempDict setValue:[NSNumber numberWithInt:0] forKey:@"LocationStatus"];
                }
                
                [favoriteArray replaceObjectAtIndex:idxSelected withObject:tempDict];
                [resultArray replaceObjectAtIndex:indx withObject:tempDict];
                favoriteArray = [[self sortArrayByFavorite:favoriteArray] mutableCopy];
                [self updateHistory];
                [_tableView reloadData];
            }
            
            else {
                
                tempDict = [[resultArray objectAtIndex:idxSelected] mutableCopy];
                int indx = [favoriteArray indexOfObject:tempDict];
                NSNumber *locationStatus = [tempDict valueForKey:@"LocationStatus"];
                if ([locationStatus intValue] == 0) {
                    [tempDict setValue:[NSNumber numberWithInt:1] forKey:@"LocationStatus"];
                }
                else if ([locationStatus intValue] == 1) {
                    [tempDict setValue:[NSNumber numberWithInt:0] forKey:@"LocationStatus"];
                }
                
                [resultArray replaceObjectAtIndex:idxSelected withObject:tempDict];
                [favoriteArray replaceObjectAtIndex:indx withObject:tempDict];
                favoriteArray = [[self sortArrayByFavorite:favoriteArray] mutableCopy];
                [self updateHistory];
                [_tableView reloadData];
            }
        }
        
        else if (buttonIndex == 2) {
            [self updateAddress];
            if (_isNotificationOn) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else{
                [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
//                [self dismissViewControllerAnimated:YES completion:nil];
//                [self.delegate backButtonClick:self];
            }
            [_myDelegate createButtonPressed];
        }
    }
   
    // If the alert view is show on clicking the search filtered places.
    else if (alertView11.tag == 9001) {
        
        // If add/remove favroites option is selected from alertView.
        if (buttonIndex ==1) {
            // TODO: Handle add to favorites for filtered search results.
            
            NSMutableDictionary * temporatyDictFromSearchResults = [[NSMutableDictionary alloc] init];
            
            temporatyDictFromSearchResults = [[self.historySearchResults objectAtIndex:idxSelected] mutableCopy];
            int indx = [self returnIndexOfLocation:temporatyDictFromSearchResults inArray:resultArray];
            int favArrayIndex = [self returnIndexOfLocation:temporatyDictFromSearchResults inArray:favoriteArray];
            tempDict = [[resultArray objectAtIndex:indx] mutableCopy];

            NSNumber *locationStatus = [tempDict valueForKey:@"LocationStatus"];
            if ([locationStatus intValue] == 0) {
                [tempDict setValue:[NSNumber numberWithInt:1] forKey:@"LocationStatus"];
                [temporatyDictFromSearchResults setValue:[NSNumber numberWithInt:1] forKey:@"LocationStatus"];
                
            }
            else if ([locationStatus intValue] == 1) {
                [tempDict setValue:[NSNumber numberWithInt:0] forKey:@"LocationStatus"];
                [temporatyDictFromSearchResults setValue:[NSNumber numberWithInt:1] forKey:@"LocationStatus"];
            }
            
            [favoriteArray replaceObjectAtIndex:favArrayIndex withObject:tempDict];
            [resultArray replaceObjectAtIndex:indx withObject:tempDict];
            favoriteArray = [[self sortArrayByFavorite:favoriteArray] mutableCopy];
            [self updateHistory];
            [self updateHistorySearchResults];
            [_tableView reloadData];
            
            
            [self.searchController.searchResultsTableView beginUpdates];
            [self.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[self.indexPathOfSearchTableSelected] withRowAnimation:UITableViewRowAnimationNone];
            [self.searchController.searchResultsTableView endUpdates];

        }
        
        else if (buttonIndex == 2) {
            [self updateAddressFromFilteredSearch];
            if (_isNotificationOn) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else{
                [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
                //                [self dismissViewControllerAnimated:YES completion:nil];
                //                [self.delegate backButtonClick:self];
            }
            [_myDelegate createButtonPressed];
        }

    }
    
    else {
        
        if (buttonIndex==1)
        {
            if ([_sortSwitch isOn]) {
                
                //NSString *string = [resultArray objectAtIndex:alertView11.tag];
                tempDict = [[favoriteArray objectAtIndex:alertView11.tag] mutableCopy];
                int indx = [resultArray indexOfObject:tempDict];
                NSString *string = [tempDict valueForKey:@"LocationString"];
                NSArray *arr=[string componentsSeparatedByString:@"\n"];
                
                if ([arr count]==3) {
                    
                    NSArray *str_array = [string componentsSeparatedByString:@","];
                    NSString *finalStr=[string stringByReplacingOccurrencesOfString:[str_array objectAtIndex:0] withString:[alertView11 textFieldAtIndex:0].text];
                    [tempDict setValue:finalStr forKey:@"LocationString"];
                    [favoriteArray replaceObjectAtIndex:alertView11.tag withObject:tempDict];
                    //
                }
                else {
                    
                    NSString *finalStr=[NSString stringWithFormat:@"%@, %@ \n 1",[[alertView11 textFieldAtIndex:0] text],string];
                    [tempDict setValue:finalStr forKey:@"LocationString"];
                    [favoriteArray replaceObjectAtIndex:alertView11.tag withObject:tempDict];
                }
                [resultArray replaceObjectAtIndex:indx withObject:tempDict];
                favoriteArray = [[self sortArrayByFavorite:favoriteArray] mutableCopy];
                [self updateHistory];
                [_tableView reloadData];
            }
            
            else {
                
                //NSString *string = [resultArray objectAtIndex:alertView11.tag];
                tempDict = [[resultArray objectAtIndex:alertView11.tag] mutableCopy];
                int indx1 = [favoriteArray indexOfObject:tempDict];
                NSString *string = [tempDict valueForKey:@"LocationString"];
                NSArray *arr=[string componentsSeparatedByString:@"\n"];
                
                if ([arr count]==3) {
                    NSArray *str_array = [string componentsSeparatedByString:@","];
                    NSString *finalStr=[string stringByReplacingOccurrencesOfString:[str_array objectAtIndex:0] withString:[alertView11 textFieldAtIndex:0].text];
                    [tempDict setValue:finalStr forKey:@"LocationString"];
                    [resultArray replaceObjectAtIndex:alertView11.tag withObject:tempDict];
                }
                else {
                    //NSArray *str_array = [string componentsSeparatedByString:@","];
                    NSString *finalStr=[NSString stringWithFormat:@"%@, %@ \n 1",[[alertView11 textFieldAtIndex:0] text],string];//[string stringByReplacingOccurrencesOfString:[str_array objectAtIndex:0] withString:[alertView11 textFieldAtIndex:0].text];
                    //finalStr=
                    [tempDict setValue:finalStr forKey:@"LocationString"];
                    [resultArray replaceObjectAtIndex:alertView11.tag withObject:tempDict];
                }
                [favoriteArray replaceObjectAtIndex:indx1 withObject:tempDict];
                favoriteArray = [[self sortArrayByFavorite:favoriteArray] mutableCopy];
                [self updateHistory];
                [_tableView reloadData];
            }
        }
    }
    
}

#pragma mark data operation
-(void)updateHistory
{
    NSUserDefaults *dataDefault = [NSUserDefaults standardUserDefaults];
    [dataDefault removeObjectForKey:@"History"];
    [dataDefault setObject:resultArray forKey:@"History"];
    // Update data on the iCloud
    [[NSUbiquitousKeyValueStore defaultStore] setArray:resultArray forKey:@"HistoryNew"];
}

- (NSMutableArray *)sortArrayByFavorite:(NSMutableArray *)historyArray
{
    NSMutableArray *sortedArray = [[[NSMutableArray alloc]init] autorelease];
    
    for (NSDictionary *dict in historyArray) {
        if ([[dict valueForKey:@"LocationStatus"] intValue] == 1) {
            [sortedArray addObject:dict];
        }
    }
    
    for (NSDictionary *dict in historyArray) {
        if ([[dict valueForKey:@"LocationStatus"] intValue] == 0) {
            [sortedArray addObject:dict];
        }
    }
    NSLog(@"Sorted  %@",sortedArray);
    return sortedArray;
}


-(void)switchPressed:(id)sender
{
    NSUserDefaults *dataDefault = [NSUserDefaults standardUserDefaults];
    if ([_sortSwitch isOn]) {
        [dataDefault setBool:YES forKey:@"isSwitchEnabled"];
    }
    else {
        [dataDefault setBool:NO forKey:@"isSwitchEnabled"];
    }
    [dataDefault synchronize];
    [_tableView reloadData];
    
}
- (void)orientationChanged:(NSNotification *)notification

{
//    if (!self.isVisible)
//    {
//        return;
//    }
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
//    {
//        //TTGasStationInfoViewController tempView=self;
//        //[self dismissViewControllerAnimated:YES completion:nil];
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        TTHistoryViewController *svc =nil;
//        if (IS_IPAD) {
//            svc=[storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController_ipad_landscape"];
//        }
//        else{
//            svc=[storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController_landscape"];
//        }
//        [svc setRoute_request:route_request];
//        [svc setIsNotificationOn:NO];
//        [svc setIsDestination:self.isDestination];
//        svc.pViewController=self.presentingViewController;
//        svc.delegate=self;
//        svc.myDelegate=self.myDelegate;
//        [svc setSuperViewController:self];
//        [self presentViewController:svc animated:NO completion:^{self.isVisible=YES;}];
//        isShowingLandscapeView = YES;
//        
//        /*
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        // TTHistoryViewController *hvc = [storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
//        TTHistoryViewController *hvc =nil;
//        if (IS_IPAD) {
//            hvc=[storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController_ipad"];
//        }
//        else{
//            hvc=[storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
//        }
//        
//        [hvc setIsDestination:YES];
//        [hvc setIsNotificationOn:YES];
//        [hvc setRoute_request:route_request];
//        [hvc setMyDelegate:self];
//        //[self presentViewController:hvc animated:YES completion:nil];
//        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//        if (UIDeviceOrientationIsLandscape(deviceOrientation))
//            [self presentViewController:hvc animated:NO completion:nil];
//        else
//            [self presentViewController:hvc animated:YES completion:nil];
//         */
//        
//    }
//    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
//    {
//        [self dismissViewControllerAnimated:YES completion:nil];
//        isShowingLandscapeView = NO;
//    }
}
-(void)backButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark UISearchBar related methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"LocationString contains[c] %@", searchText];
    self.historySearchResults = [NSMutableArray arrayWithArray:[resultArray filteredArrayUsingPredicate:resultPredicate]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchController.searchBar scopeButtonTitles]                                    objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

-(int)returnIndexOfLocation :(NSMutableDictionary *)Location inArray :(NSMutableArray *) array {
   
    int indexOfLocation;
    for (id object in array) {
        if ([[object objectForKey:@"LocationString"] isEqualToString:[Location objectForKey:@"LocationString"]]) {
            indexOfLocation = [array indexOfObject:object];
        }
    }
    return indexOfLocation;
}

-(void)updateHistorySearchResults
{
    [self filterContentForSearchText:[self.searchController.searchBar text] scope:nil];
    
}


@end
