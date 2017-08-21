//
//  GameScene.m
//  SnakeGameSK
//
//  Created by Syngmaster on 21/08/2017.
//  Copyright © 2017 Syngmaster. All rights reserved.
//

#import "GameScene.h"

static const uint32_t snakeBodyCategory     =  0x1 << 0;
static const uint32_t snakeHeadCategory     =  0x1 << 1;

@interface GameScene () <SKPhysicsContactDelegate>

@property (strong, nonatomic) SKSpriteNode *snakeHead;
@property (assign, nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (assign, nonatomic) NSInteger xDirection;
@property (assign, nonatomic) NSInteger yDirection;

@end

@implementation GameScene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        self.backgroundColor = [SKColor whiteColor];
        self.physicsWorld.contactDelegate = self;
        self.snakeHead = [SKSpriteNode spriteNodeWithImageNamed:@"snake_head"];
        self.snakeHead.size = CGSizeMake(40, 40);
        self.snakeHead.position = CGPointMake(10, 10);
        self.xDirection = 0;
        self.yDirection = 0;
        
        [self addChild:self.snakeHead];
        
    }
    return self;
}

- (void)moveSnakeHead:(SKSpriteNode *)snakeHead withXDirection:(NSInteger)xDirection andYDirection:(NSInteger)yDirection {
    
    SKAction *moveAction = [SKAction moveTo:CGPointMake(self.snakeHead.position.x + xDirection, self.snakeHead.position.y + yDirection) duration:0.5];
    //SKAction *moveDoneAction = [SKAction stop];
    [self.snakeHead runAction:[SKAction sequence:@[moveAction]]];
    
}

- (void)update:(NSTimeInterval)currentTime {
    
    [self moveSnakeHead:self.snakeHead withXDirection:self.xDirection andYDirection:self.yDirection];

}


- (void)didMoveToView:(SKView *)view {
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [view addGestureRecognizer:swipeDown];
    
    [self generateNewBody];
    
}

- (void)swipeAction:(UISwipeGestureRecognizer *)sender {
    
    switch (sender.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            self.snakeHead.zRotation = M_PI/2;
            self.xDirection = self.yDirection = 0;
            self.xDirection = -40;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            self.snakeHead.zRotation = -M_PI/2;
            self.xDirection = self.yDirection = 0;
            self.xDirection = 40;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            self.snakeHead.zRotation = 0;
            self.xDirection = self.yDirection = 0;
            self.yDirection = 40;
            break;
        case UISwipeGestureRecognizerDirectionDown:
            self.snakeHead.zRotation = -M_PI;
            self.xDirection = self.yDirection = 0;
            self.yDirection = -40;
            break;

    }
    
}

- (void)generateNewBody {
    
    SKSpriteNode *newBody = [SKSpriteNode spriteNodeWithImageNamed:@"snake_body"];
    newBody.size = CGSizeMake(40, 40);
    newBody.position = CGPointMake(100, 100);
    [self addChild:newBody];

}

@end
