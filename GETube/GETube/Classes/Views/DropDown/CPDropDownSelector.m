//
//  CPDropDownSelector.m
//  ColorPicker
//
//  Created by Amit Jangirh on 06/06/13.
//  Copyright (c) 2014 wincere Inc.. All rights reserved.
//

//#import "Common.h"
#import <QuartzCore/QuartzCore.h>
#import "CPDropDownSelector.h"
#import "ThemeManager.h"
#import "UIImage+ImageMask.h"

#define kTopBorderOffset    10.0
#define kFontSize           15
#define kOffset             10

@interface CPDropDownSelector()
{
    CGFloat             mLastHeight;
    CGRect              mBoundFrame;
}

@property (nonatomic, strong) UILabel* selectedContentLabel;
@property (nonatomic, strong) UIView* tapHandlerView;
@property (nonatomic, strong) UIView* listBaseView;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, assign) NSInteger totalListCount;
@property (nonatomic, assign) CGFloat cellHeight;

- (void)initialise;
- (void)settingContentLabel;
- (UIView*)selfWindowBaseView;
- (void)settingTapHandlerView;
- (void)setTableViewFrame;
- (void)showDrop;

@end


@implementation CPDropDownSelector

@synthesize animDuration;
@synthesize delegate = mDelegate;
@synthesize dataSource = mDataSource;
@synthesize listBaseView = mListBaseView;
@synthesize allowMultiSelection = mAllowMultiSelection;

#pragma mark ------------- LIFE CYCLE

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self initialise];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialise];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[UIColor clearColor].CGColor);
    
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];

    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, lNavTextColor.CGColor);

    CGContextMoveToPoint(context, 0.0, CGRectGetHeight(rect));    // This sets up the start point
    CGContextAddLineToPoint(context, 0.0, CGRectGetHeight(rect));
    CGContextAddLineToPoint(context, CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, lNavTextColor.CGColor);
    CGContextMoveToPoint(context, CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGContextAddLineToPoint(context, CGRectGetWidth(rect), CGRectGetHeight(rect) - 9.0);
    CGContextAddLineToPoint(context, CGRectGetWidth(rect) - 12.0, CGRectGetHeight(rect));
    CGContextClosePath(context);
    CGContextFillPath(context);
    self.selectedContentLabel.textColor = lNavTextColor;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ------------- INITIALISE

- (void)initialise
{
    self.delegate = nil;
    self.dataSource = nil;
    self.animDuration = 0.2;
    self.selectedIndex = 0;
    self.totalListCount = 0;
    self.selectorTitle = kSelectorTitle;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHideNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    mBoundFrame = CGRectMake(0,kOffset,self.bounds.size.width ,768-2*kOffset);
    
    [self settingContentLabel];
    [self settingTapHandlerView];
    [self settingListView];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)settingContentLabel
{
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];

    CGRect lLaberRect = self.bounds;
    lLaberRect.origin.x = 5;
    lLaberRect.size.width -= 10;
    self.selectedContentLabel = [[UILabel alloc] initWithFrame:lLaberRect];
    self.selectedContentLabel.userInteractionEnabled = YES;
    self.selectedContentLabel.backgroundColor = [UIColor clearColor];
    self.selectedContentLabel.font = [UIFont systemFontOfSize: 14.0];;
    self.selectedContentLabel.text = self.selectorTitle;
    self.selectedContentLabel.textAlignment = NSTextAlignmentCenter;
    self.selectedContentLabel.textColor = lNavTextColor;
    [self addSubview:self.selectedContentLabel];
}

- (UIView*)selfWindowBaseView
{
    UIWindow* lMyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!lMyWindow)
    {
        lMyWindow = [[[UIApplication sharedApplication] delegate] window]; // for IBOutlet
        if (!lMyWindow)
            return nil;
    }
    
    
    return lMyWindow.rootViewController.view;
}

- (void)settingTapHandlerView
{
    // Not adding tapHandlerView untill asked to show
    UIView* lBaseView = [self selfWindowBaseView];
    self.tapHandlerView = [[UIView alloc] initWithFrame:lBaseView.bounds];
    
    UITapGestureRecognizer* lTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(tapGestureAction)];
    lTapGesture.numberOfTouchesRequired = 1;
    lTapGesture.numberOfTapsRequired = 1;
    [self.tapHandlerView  addGestureRecognizer:lTapGesture];
}

- (void)settingListView
{
    mListBaseView = [[UIView alloc] initWithFrame:self.bounds];
    mListBaseView.layer.shadowColor = [UIColor grayColor].CGColor;
    mListBaseView.layer.shadowRadius = 6.0;
    mListBaseView.layer.shadowOpacity = 1.0;
    mListBaseView.layer.shadowOffset = CGSizeMake(2.0, 3.0);
    mListBaseView.clipsToBounds = NO;
    mListBaseView.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:mListBaseView.bounds
                                                  style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [mListBaseView addSubview:self.tableView];
}

#pragma mark ------------- CATEGORIES OVERRIDE FUNCTION

- (void)removeHighlight
{
    [self.layer removeAllAnimations];
}

- (void)makeEnable:(BOOL)enable
{
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];

    UIColor* lDisableColor = [UIColor colorWithRed: 235.0/255.0 green: 235.0/255.0 blue: 235.0/255.0 alpha: 0.9];
    UIColor* lTextCOlor = enable ? lNavTextColor : lNavColor;
    
    self.userInteractionEnabled = enable;
    self.selectedContentLabel.textColor = lTextCOlor;
    self.backgroundColor = enable ? [UIColor whiteColor] : lDisableColor;
}

- (void)showHighlightWithAnimation:(BOOL)anim
{
    if (anim)
    {
        CABasicAnimation *lShakeAnim = (CABasicAnimation*)[self.layer animationForKey:@"shakeAnimation"];
        if (lShakeAnim)
            return;
        
        CGFloat lOffset = 7.0f;
        
        lShakeAnim = [CABasicAnimation animationWithKeyPath:@"position"];
        lShakeAnim.duration = 0.05;
        lShakeAnim.repeatCount = 3;
        lShakeAnim.autoreverses = YES;
        lShakeAnim.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x - lOffset, self.center.y)];
        lShakeAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x + lOffset, self.center.y)];
        [self.layer addAnimation:lShakeAnim forKey:@"shakeAnimation"];
    }
}

- (void)reloadData
{
    [self.tableView reloadData];
}

#pragma mark ------------- TOUCH HANDLING

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self showDrop];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[self hideDrop];
}

#pragma mark ------------- TAP GESTURE

- (void)tapGestureAction
{
    [self hideDrop];
}

#pragma mark ------------- GETTER & SETTER (TEXT)

- (void)setFont:(UIFont*)font
{
    self.selectedContentLabel.font = font;
}

- (void)setText:(NSString*)text;
{
    self.selectedIndex = 0;  // setting it to default
    self.selectedContentLabel.text = text;
    NSInteger lCount = [self.dataSource numberOfRowsInDropDownSelector:self];
    if (!self.shouldHideSelectLabel)
        lCount++;
    
    for(int index = 0 ;index < lCount; index++)
    {
        NSString* lText;
        if (index == 0 && !self.shouldHideSelectLabel)
            lText =  self.selectorTitle;
        else if(!self.shouldHideSelectLabel)
            lText =  [self.dataSource dropDownSelector:self textForRow:index-1];
        else
            lText =  [self.dataSource dropDownSelector:self textForRow:index];
    
        if ([lText isEqualToString:text])
        {
            self.selectedIndex = index;
            break;
        }
    }
}

- (NSString*)getText
{
    if(self.selectedContentLabel.text.length == 0)
        return @"";
    else if([self.selectedContentLabel.text isEqualToString:self.selectorTitle])
        return @"";
    
    return self.selectedContentLabel.text;
}

#pragma mark ------------- SHOW / HIDE

- (void)showDrop
{
    [self.superview endEditing:YES];
    [self removeHighlight];
    
    UIView* lBaseView = [self selfWindowBaseView];
    if (self.tapHandlerView.superview == nil)
        [lBaseView addSubview:self.tapHandlerView];
    
    [self setTableViewFrame];
    //[self checkForPanning];
    [self.tableView reloadData];
    
    if (mListBaseView.superview == nil)
        [lBaseView addSubview:mListBaseView];
    
    mListBaseView.alpha = 0.0;
    self.tapHandlerView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:self.animDuration
                     animations:^{
                         self.tapHandlerView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.25];
                         mListBaseView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)hideDrop
{
    [UIView animateWithDuration:self.animDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         mListBaseView.alpha = 0.0;
                         self.tapHandlerView.backgroundColor = [UIColor clearColor];
                     }
                     completion:^(BOOL finished){
                         [self.tapHandlerView removeFromSuperview];
                         [mListBaseView removeFromSuperview];
                     }];
}

#pragma mark ------------- KEYBOARD HIDE NOTIFICATION

- (void)keyboardDidHideNotification:(NSNotification*)notification
{
    NSTimeInterval lDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect lFrame = mListBaseView.frame;
    [UIView animateWithDuration:lDuration
                     animations:^{
                         mListBaseView.frame = lFrame;
                     }];
}

#pragma mark ------------- SETTING TABLE VIEW FRAME

- (void)setTableViewFrame
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfRowsInDropDownSelector:)])
    {
        self.totalListCount =  [self.dataSource numberOfRowsInDropDownSelector:self];
    }
    if (!self.shouldHideSelectLabel)
        self.totalListCount++;
    
    self.cellHeight = self.frame.size.height;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(dropDownSelector:heightForRow:)])
    {
        self.cellHeight =  [self.dataSource dropDownSelector:self heightForRow:0];
    }
    
    CGRect lSelfFrame = [self.superview convertRect:self.frame toView:self.tapHandlerView];
    CGFloat lTotalPopOverHeight = self.cellHeight*self.totalListCount;
    CGFloat lAvailableHeightBelowSelf = CGRectGetMaxY(mBoundFrame) - CGRectGetMinY(lSelfFrame);
    CGFloat lExceddedHeight = lTotalPopOverHeight - lAvailableHeightBelowSelf;
    CGFloat lAllowedPopOverHeight = (lExceddedHeight > 0) ? lAvailableHeightBelowSelf : lTotalPopOverHeight;
    CGPoint lSetToOffset = CGPointZero;
    
    CGRect lPopOverRect = lSelfFrame;
    lPopOverRect.origin.y += CGRectGetHeight(lSelfFrame);
    lPopOverRect.origin.y += 2.0;
    lPopOverRect.size.height =  lAllowedPopOverHeight;
    
    //for multipple selection
    if (mAllowMultiSelection)
    {
        lPopOverRect.origin.y += lSelfFrame.size.height;
        if (CGRectGetMaxY(lPopOverRect) > CGRectGetMaxY(mBoundFrame))
        {
            lPopOverRect.size.height -= (CGRectGetMaxY(lPopOverRect) - CGRectGetMaxY(mBoundFrame));
        }
        mListBaseView.frame = lPopOverRect;
        return;
    }
    
#if 0
    if (self.selectedIndex > 0)
    {
        //Origin Shift :::::::
        CGFloat lAvailableTopMargin = CGRectGetMinY(lSelfFrame) - CGRectGetMinY(mBoundFrame);
        CGFloat lUpYShift = self.selectedIndex * self.cellHeight;
        lPopOverRect.origin.y -= lUpYShift;
        
        CGFloat lExcededUpShift = lUpYShift - lAvailableTopMargin;
        if(lExcededUpShift > 0)
        {
            lPopOverRect.origin.y += lExcededUpShift;
            lSetToOffset.y = lExcededUpShift;
        }
        
        //Height calculatin ::::::
        // setting above height
        if (lExcededUpShift > 0)
        {
            lPopOverRect.size.height = CGRectGetMaxY(lSelfFrame) - CGRectGetMinY(mBoundFrame);
        }
        else
        {
            lPopOverRect.size.height = lUpYShift+self.cellHeight;
        }
        
        // setting below height
        NSInteger lRemainingCells = (self.totalListCount - (self.selectedIndex+1));
        lAvailableHeightBelowSelf = CGRectGetMaxY(mBoundFrame) - CGRectGetMaxY(lSelfFrame);
        CGFloat lRequiredHeightForRemainingCells = lRemainingCells * self.cellHeight;
        CGFloat lBelowHeight = (lRequiredHeightForRemainingCells > lAvailableHeightBelowSelf) ?  lAvailableHeightBelowSelf : lRequiredHeightForRemainingCells;
        lPopOverRect.size.height += lBelowHeight;
    }
#endif
    [self.tableView setContentOffset: lSetToOffset animated: YES];
    mListBaseView.frame = lPopOverRect;
}

#pragma mark ------------- Panning

- (void)checkForPanning
{
    UIView* lTouchHandler = self.listBaseView.superview;
    for (UIGestureRecognizer* lGesture in [lTouchHandler gestureRecognizers])
    {
        if ([lGesture isKindOfClass:[UIPanGestureRecognizer class]])
        {
            [lTouchHandler removeGestureRecognizer:lGesture];
        }
    }
    
    UIPanGestureRecognizer* lPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(panGestureRecognizer:)];
    lPanGesture.maximumNumberOfTouches = 1;
    [lTouchHandler addGestureRecognizer:lPanGesture];
    lPanGesture.enabled = NO;
    
    CGFloat lTotalHeight = self.totalListCount * self.cellHeight;
    if (mListBaseView.frame.size.height < lTotalHeight)
    {
        lPanGesture.enabled = YES;
    }
    if (mAllowMultiSelection)
    {
        lPanGesture.enabled = NO;
    }
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer*)panGesture
{
    CGPoint lTranslatedPoint = [panGesture translationInView:mListBaseView.superview];
    if ([panGesture state] == UIGestureRecognizerStateBegan)
    {
        mLastHeight = mListBaseView.frame.size.height;
    }
    
    CGRect lRect = mListBaseView.frame;
    CGPoint lVelocity = [panGesture velocityInView:mListBaseView.superview];
    if (lVelocity.y > 0)
    {
        if (lTranslatedPoint.y < 0)
            return;
        
        lTranslatedPoint.y += mLastHeight;
        CGFloat lListHeight = self.totalListCount * self.cellHeight;
        CGFloat lTotalHeight = lListHeight + CGRectGetMinY(mListBaseView.frame);
        CGFloat lMaxAllowedHeight = CGRectGetMaxY(mBoundFrame);
        if (lTotalHeight < lMaxAllowedHeight)
        {
            if (lTranslatedPoint.y > lTotalHeight)
                lTranslatedPoint.y = lTotalHeight;
        }
        
        if ([panGesture state] == UIGestureRecognizerStateChanged)
        {
            lRect.size.height = lTranslatedPoint.y;
        }
        else if ([panGesture state] == (UIGestureRecognizerStateEnded | UIGestureRecognizerStateCancelled))
        {
            lRect.size.height = lTranslatedPoint.y;
        }
    }
    else
    {
        mLastHeight = mListBaseView.frame.size.height;
    }
    
    mListBaseView.frame = lRect;
}

#pragma mark ------------- TableviewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfRowsInDropDownSelector:)])
    {
        NSInteger lCount = [self.dataSource numberOfRowsInDropDownSelector:self];
        return  (!self.shouldHideSelectLabel)?lCount+1:lCount;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* lIdentifier = @"Identifier";
    UITableViewCell* lCell = [tableView dequeueReusableCellWithIdentifier:lIdentifier];
    if (lCell == nil)
    {
        lCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lIdentifier];
        lCell.selectionStyle = UITableViewCellSelectionStyleGray;
        if ([lCell respondsToSelector:@selector(setSeparatorInset:)])
        {
            lCell.separatorInset = UIEdgeInsetsZero;
        }
        if ([lCell respondsToSelector:@selector(setLayoutMargins:)])
        {
            lCell.layoutMargins = UIEdgeInsetsZero;
        }
        if ([lCell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
        {
            lCell.preservesSuperviewLayoutMargins = NO;
        }
        
        CGRect lAccessoryRect = self.bounds;
        lAccessoryRect.origin.x = CGRectGetWidth(self.bounds) - 15.0;
        lAccessoryRect.origin.y = (CGRectGetHeight(lCell.bounds) - 15.0)/2;
        lAccessoryRect.size.width = 15.0; lAccessoryRect.size.height = 15.0;
        UIImageView* lAccessoryView = [[UIImageView alloc] initWithFrame: lAccessoryRect];
        lAccessoryView.tag = 515;
        lAccessoryView.image = [UIImage imageWithName: @"tick.png"];
        [lCell addSubview: lAccessoryView];
    }
    
    lCell.backgroundColor = [UIColor clearColor];
    lCell.textLabel.font = [UIFont systemFontOfSize: 14.0];;
    lCell.textLabel.numberOfLines = 3;
    lCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString* lText= @"";
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(dropDownSelector:textForRow:)])
    {
        if (indexPath.row == 0 && !self.shouldHideSelectLabel)
            lText =  self.selectorTitle;
        else if(!self.shouldHideSelectLabel)
            lText =  [self.dataSource dropDownSelector:self textForRow:indexPath.row-1];
        else
            lText =  [self.dataSource dropDownSelector:self textForRow:indexPath.row];
    }
    lCell.textLabel.text = lText;

    lCell.accessoryType = UITableViewCellAccessoryNone;
    UIImageView* lAccessoryView = [lCell viewWithTag: 515];
    lAccessoryView.image = nil;
    if ([self.selectedContentLabel.text isEqualToString:lText] && !mAllowMultiSelection)
    {
        lAccessoryView.image = [UIImage imageWithName: @"tick.png"];
        self.selectedIndex = indexPath.row;
    }

    if (mAllowMultiSelection)
    {
         BOOL lSelected = NO;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(dropDownSelector:shouldShowSelectedRow:)])
        {
           lSelected = [self.delegate dropDownSelector:self shouldShowSelectedRow:indexPath.row];
        }
        else
        {
           
            NSArray *lSperatedArray = [self.selectedContentLabel.text componentsSeparatedByString:@","];
            for(NSString *lString in lSperatedArray)
            {
                if([lString isEqualToString: lText ])
                {
                    lSelected = YES;
                    break;
                }
            }
        }
    }
    
    return  lCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect lAccessoryRect = self.bounds;
    lAccessoryRect.origin.x = CGRectGetWidth(self.bounds) - 15.0;
    lAccessoryRect.origin.y = (CGRectGetHeight(cell.bounds) - 15.0)/2;
    lAccessoryRect.size.width = 15.0; lAccessoryRect.size.height = 15.0;
    UIImageView* lAccessoryView = [cell viewWithTag: 515];
    lAccessoryView.frame = lAccessoryRect;
}

#pragma mark ------------- TableviewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(dropDownSelector:heightForRow:)])
    {
        return [self.dataSource dropDownSelector:self heightForRow:indexPath.row];
    }
    return self.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* lSelectedText;
    
    if (indexPath.row == 0 && !self.shouldHideSelectLabel)
        lSelectedText =  self.selectorTitle;
    else if(!self.shouldHideSelectLabel)
        lSelectedText =  [self.dataSource dropDownSelector:self textForRow:indexPath.row-1];
    else
        lSelectedText =  [self.dataSource dropDownSelector:self textForRow:indexPath.row];

    if (mAllowMultiSelection)
    {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath: indexPath];
        BOOL lSelected = (cell.accessoryType == UITableViewCellAccessoryCheckmark) ? YES : NO;
        cell.accessoryType = lSelected ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;

//        if (lSelected == NO)
//        {
//            if (self.selectedContentLabel.text.length != 0)
//            {
//                lSelectedText = [self.selectedContentLabel.text stringByAppendingFormat:@",%@",lSelectedText];
//            }
//        }
//        else
//        {
//            NSRange lRange = [self.selectedContentLabel.text rangeOfString:lSelectedText];
//            if (lRange.location != NSNotFound)
//            {
//                lSelectedText = [self.selectedContentLabel.text stringByReplacingCharactersInRange:lRange withString:@""];
//                 NSRange lNewRange = [lSelectedText rangeOfString:@",,"];
//                if (lNewRange.location != NSNotFound)
//                {
//                    lSelectedText = [lSelectedText stringByReplacingCharactersInRange:lNewRange withString:@","];
//                }
//            }
//        }
//
//        if([lSelectedText hasSuffix:@","])
//            lSelectedText = [lSelectedText substringToIndex:lSelectedText.length - 1];
//        if([lSelectedText hasPrefix:@","])
//            lSelectedText = [lSelectedText substringFromIndex:1];
//
//        self.selectedContentLabel.text = lSelectedText;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(dropDownSelector:didSelected:row:)])
        {
            [self.delegate dropDownSelector:self didSelected:!lSelected row:indexPath.row];
        }
        
        [tableView reloadData];
    }
    else
    {
        self.selectedIndex = indexPath.row;
        self.selectedContentLabel.text = lSelectedText;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(dropDownSelector:didSelectedRow:)])
        {
            [self.delegate dropDownSelector:self didSelectedRow:indexPath.row];
        }
        [self hideDrop];
    }
}

@end
