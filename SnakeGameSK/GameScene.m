//
//  GameScene.m
//  SnakeGameSK
//
//  Created by Syngmaster on 21/08/2017.
//  Copyright © 2017 Syngmaster. All rights reserved.
//

#import "GameScene.h"

static const uint32_t snakeHeadCategory     =  0x1 << 0;
static const uint32_t snakeBodyCategory     =  0x1 << 1;

@interface GameScene () <SKPhysicsContactDelegate>

@property (strong, nonatomic) SKSpriteNode *snakeHead;
@property (strong, nonatomic) NSMutableArray *snakeBody;

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
        self.physicsWorld.gravity = CGVectorMake(0,0);
        
        CGFloat body = 20.f;

        CGFloat startX = body * arc4random_uniform(size.width/body);
        CGFloat startY = body * arc4random_uniform(size.height/body);
        
        self.snakeHead = [SKSpriteNode spriteNodeWithImageNamed:@"snake_head"];
        self.snakeHead.size = CGSizeMake(40, 40);
        self.snakeHead.position = CGPointMake(startX, startY);
        self.snakeHead.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.snakeHead.size];
        self.snakeHead.physicsBody.categoryBitMask = snakeHeadCategory;
        self.snakeHead.physicsBody.contactTestBitMask = snakeBodyCategory;
        self.snakeHead.physicsBody.dynamic = YES;
        self.snakeHead.physicsBody.allowsRotation = NO;
        self.snakeHead.physicsBody.affectedByGravity = NO;

        
        
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
    
    
    /*for (NSInteger i = [self.snakeBody count] - 1; i > 0; i--) {
        
        SKSpriteNode *firstNode = self.snakeBody[i-1];
        SKSpriteNode *secondNode = self.snakeBody[i];
        
        secondNode.position = firstNode.position;
    }*/
    
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
    
    CGFloat body = 20.f;
    
    CGFloat startX = body * arc4random_uniform(self.size.width/body);
    CGFloat startY = body * arc4random_uniform(self.size.height/body);
    
    SKSpriteNode *snakeBody = [SKSpriteNode spriteNodeWithImageNamed:@"snake_body"];
    snakeBody.size = CGSizeMake(40, 40);
    snakeBody.position = CGPointMake(startX, startY);
    snakeBody.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:snakeBody.size];
    snakeBody.physicsBody.categoryBitMask = snakeBodyCategory;
    snakeBody.physicsBody.contactTestBitMask = snakeHeadCategory;
    snakeBody.physicsBody.dynamic = NO;
    snakeBody.physicsBody.allowsRotation = NO;
    snakeBody.physicsBody.affectedByGravity = NO;

    [self addChild:snakeBody];
    [self.snakeBody addObject:snakeBody];
}

- (void)snakeHead:(SKSpriteNode *)snakeHead contactedWithSnakeBody:(SKSpriteNode *)snakeBody {
    
    [snakeBody removeFromParent];
    [self generateNewBody];
        
    snakeBody.position = CGPointMake(snakeHead.position.x, snakeHead.position.y - 40 * (1 + (int)[snakeHead.children count]));
    [self addChild:snakeBody];
    
    NSLog(@"children - %lu", (unsigned long)[self.children count]);
    
    if ((int)[self.children count] == 3) {
        
        
        SKPhysicsJointFixed *connect = [SKPhysicsJointFixed jointWithBodyA:snakeHead.physicsBody bodyB:snakeBody.physicsBody anchor:CGPointMake(CGRectGetMidX(snakeHead.frame), CGRectGetMidY(snakeHead.frame))];
        [self.physicsWorld addJoint:connect];
        
    } else {
        
        SKPhysicsJointFixed *connect = [SKPhysicsJointFixed jointWithBodyA:snakeHead.physicsBody bodyB:snakeBody.physicsBody anchor:CGPointMake(CGRectGetMidX(snakeHead.frame), CGRectGetMidY(snakeHead.frame))];
        [self.physicsWorld addJoint:connect];
        
    }


    //NSLog(@"snakeHead - %@", NSStringFromCGPoint(snakeHead.position));
    //NSLog(@"snakeBody - %@", NSStringFromCGPoint(snakeBody.position));

}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
        
    } else {
        
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
        
    }
    
    if (((firstBody.categoryBitMask & snakeHeadCategory) != 0 &&
         (secondBody.categoryBitMask & snakeBodyCategory) != 0)) {
        
        [self snakeHead:(SKSpriteNode *)firstBody.node contactedWithSnakeBody:(SKSpriteNode *)secondBody.node];
        
    }
    
}

@end
