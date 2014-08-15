//
//  PSPDFAlertView.m
//
//  Copyright (c) 2011-2014 PSPDFKit GmbH. All rights reserved.
//

#import "PSPDFAlertView.h"

@interface PSPDFAlertView () <UIAlertViewDelegate>
@property (nonatomic, assign, getter=isDismissing) BOOL dismissing;
@property (nonatomic, copy) NSArray *blocks;
@property (nonatomic, copy) NSArray *willDismissBlocks;
@property (nonatomic, copy) NSArray *didDismissBlocks;
@property (nonatomic, weak) id<UIAlertViewDelegate> realDelegate;
@end

@implementation PSPDFAlertView

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)init {
    if (self = [super init]) {
        [super setDelegate:self];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title {
    return self = [self initWithTitle:title message:nil];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    return self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
}

- (void)dealloc {
    self.delegate = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p numberOfButtons:%zd title:%@>", NSStringFromClass(self.class), self, self.numberOfButtons, self.title];
}

- (void)destroy {
    self.blocks = nil;
    self.willDismissBlocks = nil;
    self.didDismissBlocks = nil;
    self.delegate = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)setDelegate:(id/**<UIAlertViewDelegate>*/)delegate {
    [super setDelegate:delegate ? self : nil];
    self.realDelegate = delegate != self ? delegate : nil;
}

- (NSInteger)setCancelButtonWithTitle:(NSString *)title block:(void (^)(NSInteger buttonIndex))block {
    NSUInteger buttonIndex = [self addButtonWithTitle:title block:block];
    self.cancelButtonIndex = buttonIndex;
    return buttonIndex;
}

- (NSInteger)addButtonWithTitle:(NSString *)title block:(void (^)(NSInteger buttonIndex))block {
    NSParameterAssert(title);
    self.blocks = [[NSArray arrayWithArray:self.blocks] arrayByAddingObject:block ? [block copy] : NSNull.null];
    return [self addButtonWithTitle:title];
}

- (NSInteger)addButtonWithTitle:(NSString *)title {
    NSInteger buttonIndex = [super addButtonWithTitle:title];

    // Ensure blocks array is equal to number of buttons.
    while (self.blocks.count < self.numberOfButtons) {
        self.blocks = [[NSArray arrayWithArray:self.blocks] arrayByAddingObject:NSNull.null];
    }

    return buttonIndex;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];

    // In iOS 8, this method is being called even when we dismissed based on a button action.
    // It's not called on iOS 7 or earlier. We track if it's a user-initiated or programmatic
    // dismissal via `isDismissing`.
    if (!self.isDismissing) {
        [self alertView:self clickedButtonAtIndex:buttonIndex];
    }
}

- (void)addWillDismissBlock:(void (^)(NSInteger buttonIndex))willDismissBlock {
    NSParameterAssert(willDismissBlock);
    self.willDismissBlocks = [[NSArray arrayWithArray:self.willDismissBlocks] arrayByAddingObject:willDismissBlock];
}

- (void)addDidDismissBlock:(void (^)(NSInteger buttonIndex))didDismissBlock {
    NSParameterAssert(didDismissBlock);
    self.didDismissBlocks = [[NSArray arrayWithArray:self.didDismissBlocks] arrayByAddingObject:didDismissBlock];
}

- (void)_callBlocks:(NSArray *)blocks withButtonIndex:(NSInteger)buttonIndex {
    for (void (^block)(NSInteger buttonIndex) in blocks) {
        block(buttonIndex);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Run the button's block.
    if (buttonIndex >= 0 && buttonIndex < self.blocks.count) {
        void (^block)(NSUInteger) = self.blocks[buttonIndex];
        if (![block isEqual:NSNull.null]) {
            block(buttonIndex);
        }
    }

    id<UIAlertViewDelegate> delegate = self.realDelegate;
    if ([delegate respondsToSelector:_cmd]) {
        [delegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.dismissing = YES;
    [self _callBlocks:self.willDismissBlocks withButtonIndex:buttonIndex];

    id<UIAlertViewDelegate> delegate = self.realDelegate;
    if ([delegate respondsToSelector:_cmd]) {
        [delegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self _callBlocks:self.didDismissBlocks withButtonIndex:buttonIndex];

    id<UIAlertViewDelegate> delegate = self.realDelegate;
    if ([delegate respondsToSelector:_cmd]) {
        [delegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }

    [self destroy];
    self.dismissing = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegate Forwarder

- (BOOL)respondsToSelector:(SEL)s {
    return [super respondsToSelector:s] || [self.realDelegate respondsToSelector:s];
}

- (id)forwardingTargetForSelector:(SEL)s {
    id delegate = self.realDelegate;
    return [delegate respondsToSelector:s] ? delegate : [super forwardingTargetForSelector:s];
}

@end
