//
//  TTOdoViewController.m
//  TruckRoute
//
//  Created by admin on 3/27/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTOdoViewController.h"
#import "TTUtilities.h"
#import "TTStateOdoCell.h"
#import "TTConfig.h"

@interface TTOdoViewController ()

@end

@implementation TTOdoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    isUnitMetric = [userDefaults boolForKey:@"Metric"];
    
    //update datasource
    arrayUSA = [[NSMutableArray alloc]init];
    arrayCANADA = [[NSMutableArray alloc]init];
    [self updateStateOdo];
    timer = [NSTimer scheduledTimerWithTimeInterval:ODOMETER_INTERVAL target:self selector:@selector(updateStateOdo) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [timer invalidate];
    [timer release];
    [arrayUSA release];
    [arrayCANADA release];
    [_tableView release];
    [super dealloc];
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reset:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                       message:@"Reset Odometer?"
                                      delegate:self
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:@"Cancel", nil];
    [alert show];
    [alert release];
}
-(void)updateStateOdo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *total = [userDefaults objectForKey:@"odometer_total_distance"];
    double dist_in_meters = [total doubleValue];
    if (isUnitMetric) {
        if (dist_in_meters/1000 < .1) {
            [_labelOdo setText:@"Total Distance: < 0.1 KMs"];
        }else {
            [_labelOdo setText:[NSString stringWithFormat:@"Total Distance: %.1f KMs", dist_in_meters/1000]];
        }
    }else {
        if (METERS_TO_MILES(dist_in_meters) < .1) {
            [_labelOdo setText:@"Total Distance: < 0.1 Mile"];
        }else {
            [_labelOdo setText:[NSString stringWithFormat:@"Total Distance: %.1f Miles", METERS_TO_MILES(dist_in_meters)]];
        }
    }
    
    NSString *str = nil;
    NSDictionary *dic = [userDefaults objectForKey:@"odometer_dictionary"];
    for (NSString *obj in arrayUSA) {
        [obj release];
    }
    for (NSString *obj in arrayCANADA) {
        [obj release];
    }
    [arrayUSA removeAllObjects];//clear
    [arrayCANADA removeAllObjects];//clear
    for (id key in dic) {
        if ([[key substringToIndex:2]isEqualToString:@"US"]) {
            str = [[NSString stringWithFormat:@"%@,%@", [key substringFromIndex:3] , [dic objectForKey:key]]retain];
            [arrayUSA addObject:str];
        }else {
            str = [[NSString stringWithFormat:@"%@,%@", [key substringFromIndex:3] , [dic objectForKey:key]]retain];
            [arrayCANADA addObject:str];
        }        
    }
    if (sortedUSA) {
        [sortedUSA release];
    }
    if (sortedCANADA) {
        [sortedCANADA release];
    }
    sortedUSA = [arrayUSA sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    sortedCANADA = [arrayCANADA sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [sortedUSA retain];
    [sortedCANADA retain];
//    [arrayUSA initWithArray:[tmp_arry1 sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
//    [arrayCANADA initWithArray:[tmp_arry2 sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [_tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    int n = 0;
    if (arrayUSA.count) {
        n++;
    }
    if (arrayCANADA.count) {
        n++;
    }
    return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (0 == section) {
        return arrayUSA.count;//usa
    }else {
        return arrayCANADA.count;//ca
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StateOdoCell";
    TTStateOdoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSArray *array = (0 == indexPath.section)?sortedUSA:sortedCANADA;
    
    // Configure the cell...
    NSString *string = [array objectAtIndex:[indexPath row]];
    NSArray *str_array = [string componentsSeparatedByString:@","];
    [cell.labelState setText:[str_array objectAtIndex:0]];
    
    double dist_in_meters = [[str_array objectAtIndex:1]doubleValue];
    if (isUnitMetric) {
        [cell.labelUnit setText:@"KMs"];
        if (dist_in_meters/1000 < .1) {
            [cell.labelDist setText:@"< 0.1"];
        }else {
            [cell.labelDist setText:[NSString stringWithFormat:@"%.1f", dist_in_meters/1000]];
        }
    }else {
        [cell.labelUnit setText:@"Miles"];
        if (METERS_TO_MILES(dist_in_meters) < .1) {
            [cell.labelDist setText:@"< 0.1"];
        }else {
            [cell.labelDist setText:[NSString stringWithFormat:@"%.1f", METERS_TO_MILES(dist_in_meters)]];
        }
    }
    
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == section) {
        return @"USA";
    }else {
        return @"CANADA";
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark uialertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"odometer_total_distance"];
        [userDefaults removeObjectForKey:@"odometer_dictionary"];
        [self updateStateOdo];
    }    
}
@end
