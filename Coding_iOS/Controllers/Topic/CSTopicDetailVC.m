//
//  CSTopicDetailVC.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSTopicDetailVC.h"
#import "TweetSendViewController.h"
#import "Coding_NetAPIManager.h"
#import "CSTopicHeaderView.h"

#import "TweetCell.h"
#import "Tweet.h"
#import "Tweets.h"

#import "UserInfoViewController.h"
#import "LikersViewController.h"
#import "TweetSendLocationDetailViewController.h"
#import "UIMessageInputView.h"
#import "TweetDetailViewController.h"

@interface CSTopicDetailVC ()<UITableViewDataSource,UITableViewDelegate,UIMessageInputViewDelegate>
@property (nonatomic,strong)UITableView *myTableView;

@property (nonatomic,strong)Tweets *curTweets;
@property (nonatomic,strong)Tweet *curTopWteet;
@property (nonatomic,strong)CSTopicHeaderView *tableHeader;

@property (nonatomic, strong) UIMessageInputView *myMsgInputView;
@end

@implementation CSTopicDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupData];
    [self setupUI];
    
    [self.myTableView reloadData];
    [self refreshheader];
    [self refreshTopTweet];
    [self sendRequest];
}

- (void)sendRequest{
//    Tweets *curTweets = [self getCurTweets];
//    if (curTweets.list.count <= 0) {
//        [self.view beginLoading];
//    }
    __weak typeof(self) weakSelf = self;
    
    [[Coding_NetAPIManager sharedManager] request_PublicTweetsWithTopic:_topicID andBlock:^(id data, NSError *error) {
        [weakSelf.curTweets configWithTweets:data];
        [weakSelf.myTableView reloadData];
//        [weakSelf.view endLoading];
//        [weakSelf.refreshControl endRefreshing];
//        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
//        if (data) {
//            [curTweets configWithTweets:data];
//            [weakSelf.myTableView reloadData];
//            weakSelf.myTableView.showsInfiniteScrolling = curTweets.canLoadMore;
//        }
//        [weakSelf.view configBlankPage:EaseBlankPageTypeTweet hasData:(curTweets.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
//            [weakSelf sendRequest];
//        }];
    }];
}

- (void)refreshTopTweet {
    __weak typeof(self) weakSelf = self;
    
    [[Coding_NetAPIManager sharedManager] request_TopTweetWithTopicID:_topicID block:^(id data, NSError *error) {
        if (data) {
            weakSelf.curTopWteet = data;
            [weakSelf.myTableView reloadData];
        }
    }];
}

- (void)refreshheader {
    [[Coding_NetAPIManager sharedManager]request_TopicDetailsWithTopicID:_topicID block:^(id data, NSError *error) {
        if (data) {
            [self.tableHeader updateWithTopic:data];
        }
    }];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (_curTopWteet) {
            return 2;
        }else {
            return 0;
        }
    }
    
    if (_curTweets && _curTweets.list) {
        return [_curTweets.list count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row ==0) {
        CSTopTweetDescCell *cell0 = [tableView dequeueReusableCellWithIdentifier:@"CSTopTweetDescCell" forIndexPath:indexPath];
        [cell0 updateUI];
        [tableView addLineforPlainCell:cell0 forRowAtIndexPath:indexPath withLeftSpace:0];
        return cell0;
    }
    
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Tweet forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.tweet = _curTopWteet;
    }else{
        cell.tweet = [_curTweets.list objectAtIndex:indexPath.row];
    }
    
    __weak typeof(self) weakSelf = self;
    cell.commentClickedBlock = ^(Tweet *tweet, NSInteger index, id sender){
//        if ([self.myMsgInputView isAndResignFirstResponder]) {
//            return ;
//        }
//        weakSelf.commentTweet = tweet;
//        weakSelf.commentIndex = index;
//        weakSelf.commentSender = sender;
//        
//        weakSelf.myMsgInputView.commentOfId = tweet.id;
//        
//        if (weakSelf.commentIndex >= 0) {
//            weakSelf.commentToUser = ((Comment*)[weakSelf.commentTweet.comment_list objectAtIndex:weakSelf.commentIndex]).owner;
//            weakSelf.myMsgInputView.toUser = ((Comment*)[weakSelf.commentTweet.comment_list objectAtIndex:weakSelf.commentIndex]).owner;
//            
//            if ([Login isLoginUserGlobalKey:weakSelf.commentToUser.global_key]) {
//                ESWeakSelf
//                UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此评论" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
//                    ESStrongSelf
//                    if (index == 0 && _self.commentIndex >= 0) {
//                        Comment *comment  = [_self.commentTweet.comment_list objectAtIndex:_self.commentIndex];
//                        [_self deleteComment:comment ofTweet:_self.commentTweet];
//                    }
//                }];
//                [actionSheet showInView:self.view];
//                return;
//            }
//        }else{
//            weakSelf.myMsgInputView.toUser = nil;
//        }
//        [_myMsgInputView notAndBecomeFirstResponder];
    };
    cell.likeBtnClickedBlock = ^(Tweet *tweet){
        [weakSelf.myTableView reloadData];
    };
    cell.userBtnClickedBlock = ^(User *curUser){
        UserInfoViewController *vc = [[UserInfoViewController alloc] init];
        vc.curUser = curUser;
        [self.navigationController pushViewController:vc animated:YES];
    };
    cell.moreLikersBtnClickedBlock = ^(Tweet *curTweet){
        LikersViewController *vc = [[LikersViewController alloc] init];
        vc.curTweet = curTweet;
        [self.navigationController pushViewController:vc animated:YES];
    };
     cell.goToDetailTweetBlock = ^(Tweet *curTweet){
        [self goToDetailWithTweet:curTweet];
    };

    
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    
    return cell;
}

- (void)goToDetailWithTweet:(Tweet *)curTweet{
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
    vc.curTweet = curTweet;
    __weak typeof(self) weakSelf = self;
    vc.deleteTweetBlock = ^(Tweet *toDeleteTweet){
//        Tweets *curTweets = [weakSelf.tweetsDict objectForKey:[NSNumber numberWithInteger:weakSelf.curIndex]];
//        [curTweets.list removeObject:toDeleteTweet];
//        [weakSelf.myTableView reloadData];
//        [weakSelf.view configBlankPage:EaseBlankPageTypeTweet hasData:(curTweets.list.count > 0) hasError:NO reloadButtonBlock:^(id sender) {
//            [weakSelf sendRequest];
//        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (_curTopWteet && indexPath.row ==0) {
            return 36;
        }else if(_curTopWteet && indexPath.row == 1){
            return [TweetCell cellHeightWithObj:_curTopWteet];
        }
        else {
            return 0;
        }
    }
    
    return [TweetCell cellHeightWithObj:[_curTweets.list objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.row != 0) {
//        Comment *toComment = [_curTweet.comment_list objectAtIndex:indexPath.row-1];
//        [self doCommentToComment:toComment sender:[tableView cellForRowAtIndexPath:indexPath]];
//    }
}

#pragma mark UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text{
    [self sendCommentMessage:text];
}

- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom{
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        UIEdgeInsets contentInsets= UIEdgeInsetsMake(0.0, 0.0, heightToBottom, 0.0);;
        CGFloat msgInputY = kScreen_Height - heightToBottom - 64;
        
        self.myTableView.contentInset = contentInsets;
        
//        if ([_commentSender isKindOfClass:[UIView class]] && !self.myTableView.isDragging && heightToBottom > 60) {
//            UIView *senderView = _commentSender;
//            CGFloat senderViewBottom = [_myTableView convertPoint:CGPointZero fromView:senderView].y+ CGRectGetMaxY(senderView.bounds);
//            CGFloat contentOffsetY = MAX(0, senderViewBottom- msgInputY);
//            [self.myTableView setContentOffset:CGPointMake(0, contentOffsetY) animated:YES];
//        }
    } completion:nil];
}


- (void)sendCommentMessage:(id)obj{
//    if (_commentIndex >= 0) {
//        _commentTweet.nextCommentStr = [NSString stringWithFormat:@"@%@ %@", _commentToUser.name, obj];
//    }else{
//        _commentTweet.nextCommentStr = obj;
//    }
//    [self sendCurComment:_commentTweet];
//    {
//        _commentTweet = nil;
//        _commentIndex = kCommentIndexNotFound;
//        _commentSender = nil;
//        _commentToUser = nil;
//    }
    self.myMsgInputView.toUser = nil;
    [self.myMsgInputView isAndResignFirstResponder];
}

- (void)sendCurComment:(Tweet *)commentObj{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Tweet_DoComment_WithObj:commentObj andBlock:^(id data, NSError *error) {
        if (data) {
            Comment *resultCommnet = (Comment *)data;
            resultCommnet.owner = [Login curLoginUser];
            [commentObj addNewComment:resultCommnet];
            [weakSelf.myTableView reloadData];
        }
    }];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

#pragma mark - 

- (void) setupUI {
    self.navigationItem.title = @"话题";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tweetBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(sendTweet)];
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TweetCell class] forCellReuseIdentifier:kCellIdentifier_Tweet];
        [tableView registerClass:[CSTopTweetDescCell class] forCellReuseIdentifier:@"CSTopTweetDescCell"];
        
        [self.view addSubview:tableView];
        
        CSTopicHeaderView *header = [[CSTopicHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 191)];
        header.parentVC = self;
//        [header updateWithTopic:self.topic];
        tableView.tableHeaderView = header;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        _tableHeader = header;
        tableView;
    });
    
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypeTweet];
    _myMsgInputView.delegate = self;
}

- (void)setupData {
    _curTweets = [Tweets tweetsWithType:TweetTypePublicTime];
//    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Tweet forIndexPath:indexPath];
}

- (void)sendTweet{
//    __weak typeof(self) weakSelf = self;
    TweetSendViewController *vc = [[TweetSendViewController alloc] init];
    vc.sendNextTweet = ^(Tweet *nextTweet){
        [nextTweet saveSendData];//发送前保存草稿
        [[Coding_NetAPIManager sharedManager] request_Tweet_DoTweet_WithObj:nextTweet andBlock:^(id data, NSError *error) {
            if (data) {
                [Tweet deleteSendData];//发送成功后删除草稿
//                Tweets *curTweets = [weakSelf getCurTweets];
//                if (curTweets.tweetType != TweetTypePublicHot) {
//                    Tweet *resultTweet = (Tweet *)data;
//                    resultTweet.owner = [Login curLoginUser];
//                    if (curTweets.list && [curTweets.list count] > 0) {
//                        [curTweets.list insertObject:data atIndex:0];
//                    }else{
//                        curTweets.list = [NSMutableArray arrayWithObject:resultTweet];
//                    }
//                    [self.myTableView reloadData];
//                }
//                [weakSelf.view configBlankPage:EaseBlankPageTypeTweet hasData:(curTweets.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
//                    [weakSelf sendRequest];
//                }];
            }
            
        }];
        
    };
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self.parentViewController presentViewController:nav animated:YES completion:nil];
}

@end


@implementation CSTopTweetDescCell

- (void)updateUI {
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.frame = CGRectMake(12, 0, 100, 36);
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    self.textLabel.text = @"置顶话题";
}

@end

