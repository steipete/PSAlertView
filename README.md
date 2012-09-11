PSAlertView & PSActionSheet
=============

Block-based subclasses for UIActionSheet and UIAlertView.

## How to use
``` objective-c
    PSMenuItem *actionItem = [[PSMenuItem alloc] initWithTitle:@"Action 1" block:^{
        [[[UIAlertView alloc] initWithTitle:@"Message" message:@"From a block!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];

    PSMenuItem *submenuItem = [[PSMenuItem alloc] initWithTitle:@"Submenu..." block:^{
        [UIMenuController sharedMenuController].menuItems = @[
        [[PSMenuItem alloc] initWithTitle:@"Back..." block:^{
            [self buttonPressed:button];
        }],
        [[PSMenuItem alloc] initWithTitle:@"Sub 1" block:^{
            NSLog(@"Sub 1 pressed");
        }]];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }];

    [UIMenuController sharedMenuController].menuItems = @[actionItem, submenuItem];
    [[UIMenuController sharedMenuController] setTargetRect:button.bounds inView:button];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
```

PSMenuItem uses ARC and is tested with Xcode 4.4 and 4.5DP3 (iOS 4.3+)

## Creator

[Peter Steinberger](http://github.com/steipete)
[@steipete](https://twitter.com/steipete)

I'd love a thank you tweet if you find this useful.

## License

PSAlertView is available under the MIT license. See the LICENSE file for more info.
