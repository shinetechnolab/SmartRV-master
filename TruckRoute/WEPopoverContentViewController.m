//
//  WEPopoverContentViewController.m
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverContentViewController.h"


@implementation WEPopoverContentViewController
@synthesize delegate;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
		self.contentSizeForViewInPopover = CGSizeMake(150,200);
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.title=@"Travel Alerts";
	self.tableView.rowHeight = 37;
    self.tableView.delaysContentTouches=NO;
	self.view.backgroundColor = [UIColor whiteColor];
    
    hwyArray=[[NSMutableArray alloc]init];
    descArray=[[NSMutableArray alloc]init];
    latArray=[[NSMutableArray alloc]init];
    lonArray=[[NSMutableArray alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSString *string=[NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.teletype.com/truckroutes/getTravelAlert.php"] encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"Result : %@",string);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            TBXML *tbxml=[TBXML tbxmlWithXMLString:string];
            TBXMLElement *root=tbxml.rootXMLElement;
            if(root)
            {
                TBXMLElement *statusEle=[TBXML childElementNamed:@"status" parentElement:root];
                if([[TBXML textForElement:statusEle] isEqualToString:@"1"])
                {
                    TBXMLElement *itemEle=[TBXML childElementNamed:@"item" parentElement:root];
                    while (itemEle)
                    {
                        TBXMLElement *hwyEle=[TBXML childElementNamed:@"hwy" parentElement:itemEle];
                        TBXMLElement *descEle=[TBXML childElementNamed:@"desc" parentElement:itemEle];
                        TBXMLElement *latEle=[TBXML childElementNamed:@"lat" parentElement:itemEle];
                        TBXMLElement *lonEle=[TBXML childElementNamed:@"lon" parentElement:itemEle];
                        [hwyArray addObject:[TBXML textForElement:hwyEle]];
                        [descArray addObject:[TBXML textForElement:descEle]];
                        [latArray addObject:[TBXML textForElement:latEle]];
                        [lonArray addObject:[TBXML textForElement:lonEle]];
                        itemEle=[TBXML nextSiblingNamed:@"item" searchFromElement:itemEle];
                    }
                }
            }
            [self.tableView reloadData];
            //[notificationTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        });
    });

    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)notificationLocation:(NSString *)lat longitute:(NSString *)lon
{
    [delegate selectedLocationFromNotification:lat longitute:lon];
}

#pragma mark -
#pragma mark Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    return 1;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return hwyArray.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = [hwyArray objectAtIndex:indexPath.row];//[NSString stringWithFormat:@"Item %d", [indexPath row]];
	cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font=[UIFont systemFontOfSize:15.f];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableString *latStr=[[NSMutableString alloc]initWithString:[latArray objectAtIndex:indexPath.row]];
    
    [latStr insertString:@"." atIndex:[latStr length]-6];
    
    NSMutableString *lonStr=[[NSMutableString alloc]initWithString:[lonArray objectAtIndex:indexPath.row]];
    [lonStr insertString:@"." atIndex:[lonStr length]-6];
    
    
    
    // Navigation logic may go here. Create and push another view controller.
	NSLog(@"Detail : %@ - %@",latStr,lonStr);
    TTNotificationDetailViewController *notifView=[[TTNotificationDetailViewController alloc]init];
    notifView.delegate=self;
    notifView.latString=latStr;
    notifView.lonString=lonStr;
    //notifView.detailLable.text=[descArray objectAtIndex:indexPath.row];
    notifView.detailText=[descArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:notifView animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

