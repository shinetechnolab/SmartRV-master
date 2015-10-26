//
//  TTTravelAlertView.m
//  TruckRoute
//
//  Created by Alpesh55 on 10/16/13.
//  Copyright (c) 2013 admin. All rights reserved.
//
#import "TBXML.h"
#import "TTTravelAlertView.h"

@implementation TTTravelAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor colorWithWhite:0.1 alpha:0.7];
        //self.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"travelAlertBg"]];
        notificationTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-20) style:UITableViewStyleGrouped];
        notificationTableView.backgroundColor=[UIColor clearColor];
        notificationTableView.userInteractionEnabled=YES;
        notificationTableView.rowHeight=40;

        notificationTableView.sectionFooterHeight=20;
        notificationTableView.sectionHeaderHeight=20;
        notificationTableView.scrollEnabled=YES;
        
        notificationTableView.dataSource=self;
        notificationTableView.delegate=(id <UITableViewDelegate>)self;
        [self addSubview:notificationTableView];
        
//        detailLbl=[[UILabel alloc]initWithFrame:self.bounds];
//        [self addSubview:detailLbl];
//        detailLbl.hidden=YES;
        
        
        [self loadDataFromSevice];
    }
    return self;
}
-(void)loadDataFromSevice
{
    hwyArray=[[NSMutableArray alloc]init];
    descArray=[[NSMutableArray alloc]init];
    
    
    NSString *string=[NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.teletype.com/truckroutes/getTravelAlert.php"] encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"Result : %@",string);
    
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
                [hwyArray addObject:[TBXML textForElement:hwyEle]];
                [descArray addObject:[TBXML textForElement:descEle]];
                itemEle=[TBXML nextSiblingNamed:@"item" searchFromElement:itemEle];
            }
        }
    }

    
    /*
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
                        [hwyArray addObject:[TBXML textForElement:hwyEle]];
                        [descArray addObject:[TBXML textForElement:descEle]];
                        itemEle=[TBXML nextSiblingNamed:@"item" searchFromElement:itemEle];
                    }
                }
            }
            //[notificationTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        });
    });
    */
    

}
-(void)reloadTableView
{
    [notificationTableView reloadData];
}
//-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return hwyArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [notificationTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    cell.textLabel.text=[hwyArray objectAtIndex:indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor=[UIColor whiteColor];
    //cell.backgroundColor=[UIColor clearColor];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    detailLbl.text=[descArray objectAtIndex:indexPath.row];
//    detailLbl.hidden=NO;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Value Of Index : %@",[descArray objectAtIndex:indexPath.row]);
    
//    detailLbl.text=[descArray objectAtIndex:indexPath.row];
//    detailLbl.hidden=NO;
    
//    UIView* view=self;
//    UIView* parentView = self.superview;
//    [self removeFromSuperview];
//    [parentView addSubview:view];
//    detailLbl.hidden=NO;
//    
//    CATransition *animation = [CATransition animation];
//    [animation setDelegate:self]; // set your delegate her to know when transition ended
//    
//    [animation setType:kCATransitionPush];
//    [animation setSubtype:kCATransitionFromRight]; // set direction as you need
//    
//    [animation setDuration:0.5];
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    
//    [[parentView layer] addAnimation:animation forKey:@"viewPush"];

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end