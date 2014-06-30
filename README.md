UBRSpaceView
============

A wrapper view that allows its subviews to animate between two positions but still stay responsive.
The user can interrupt and manipulate these subviews at any time.

Video
-----
* https://flic.kr/p/nSMTAs


Usage
-----

Setup the space view.

```objective-c
// Layout
UBRSpaceView * spaceView = [[UBRSpaceView alloc] initWithFrame:self.view.bounds];
spaceView.backgroundColor = [UIColor blackColor];
spaceView.delegate = self;
[self.view addSubview:spaceView];

// Setup space properties
spaceView.duration = 0.6;
spaceView.damping = 3;
spaceView.velocity = 6;

// Add subview
UIView * aSubview = [[UIView alloc] init];
[spaceView addSubview:aSubview];

// Let the space view control the subview 
[spaceView controlSubview:aSubview options:UBRSpaceViewOptionsDraggable];
```

Implement delegation methods.

```objective-c
// Required

- (CGRect)spaceView:(UBRSpaceView *)spaceView startFrameForSubview:(UIView *)view {
    // Returs start frame
    return CGRectMake(60,60,60,60);
}

- (CGRect)spaceView:(UBRSpaceView *)spaceView endFrameForSubview:(UIView *)view {
    // Returs end frame
    return CGRectMake(240,240,60,60);
}

// Optional

- (void)spaceView:(UBRSpaceView *)spaceView adjustSubview:(UIView *)view progress:(CGFloat)progress {
}

- (void)spaceView:(UBRSpaceView *)spaceView subview:(UIView *)subview willTransitFromPosition:(UBRSpaceViewPosition)position {
}

- (void)spaceView:(UBRSpaceView *)spaceView subview:(UIView *)subview didTransitToPosition:(UBRSpaceViewPosition)position {
}
```

Trigger animations.

```objective-c
[spaceView toggleSubviewPosition:subview animated:animated];
[spaceView setSubviewPosition:subview position:position animated:animated];
````
