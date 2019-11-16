//
//  LLLocationViewController.m
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "LLLocationViewController.h"

#import <MapKit/MapKit.h>

#import "LLDetailTitleSelectorCellView.h"
#import "LLTitleSwitchCellView.h"
#import "LLPinAnnotationView.h"
#import "LLInternalMacros.h"
#import "LLThemeManager.h"
#import "LLAnnotation.h"
#import "LLConst.h"

#import "UIView+LL_Utils.h"

static NSString *const kAnnotationID = @"AnnotationID";

@interface LLLocationViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) LLTitleSwitchCellView *switchView;

@property (nonatomic, strong) LLDetailTitleSelectorCellView *locationDescriptView;

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) LLAnnotation *annotation;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, assign) BOOL isAddAnnotation;

@end

@implementation LLLocationViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Mock Location";
    self.view.backgroundColor = [LLThemeManager shared].backgroundColor;
    
    [self.view addSubview:self.switchView];
    [self.view addSubview:self.locationDescriptView];
    [self.view addSubview:self.mapView];
    
    [self addSwitchViewConstraints];
    [self addLocationDescriptViewConstraints];
    [self loadData];
}

#pragma mark - Over write
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.mapView.frame = CGRectMake(0, self.locationDescriptView.LL_bottom + kLLGeneralMargin, LL_SCREEN_WIDTH, LL_SCREEN_HEIGHT - self.switchView.LL_bottom - kLLGeneralMargin);
}

#pragma mark - MKMapViewDelegate
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    if (!self.isAddAnnotation) {
        [self updateAnnotationCoordinate:mapView.region.center automicSetRegion:NO];
    }
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
}

- (void)mapViewDidChangeVisibleRegion:(MKMapView *)mapView {
//    [self updateAnnotationCoordinate:mapView.region.center automicSetRegion:NO];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    LLPinAnnotationView *annotationView = (LLPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationID];
    if (!annotationView) {
        annotationView = [[LLPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:kAnnotationID];
    }
    annotationView.annotation = annotation;
    return annotationView;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations firstObject];
    if (location) {
        [manager stopUpdatingLocation];
        [self updateAnnotationCoordinate:location.coordinate automicSetRegion:YES];
    }
}

#pragma mark - Primary
- (void)addSwitchViewConstraints {
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.switchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.switchView.superview attribute:NSLayoutAttributeTop multiplier:1 constant:LL_NAVIGATION_HEIGHT];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.switchView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.switchView.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.switchView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.switchView.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    self.switchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.switchView.superview addConstraints:@[top, left, right]];
}

- (void)addLocationDescriptViewConstraints {
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.locationDescriptView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.switchView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.locationDescriptView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.locationDescriptView.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.locationDescriptView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.locationDescriptView.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    self.locationDescriptView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.locationDescriptView.superview addConstraints:@[top, left, right]];
}

- (void)updateAnnotationCoordinate:(CLLocationCoordinate2D)coordinate automicSetRegion:(BOOL)automicSetRegion {
    self.annotation.coordinate = coordinate;
    self.annotation.title = [NSString stringWithFormat:@"%0.6f, %0.6f", coordinate.latitude, coordinate.longitude];
    self.locationDescriptView.detailTitle = [NSString stringWithFormat:@"%0.6f, %0.6f", coordinate.latitude, coordinate.longitude];
    if (automicSetRegion) {
        self.mapView.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.05, 0.05));
    }
    if (!self.isAddAnnotation) {
        self.isAddAnnotation = YES;
        [self.mapView addAnnotation:self.annotation];
        [self.mapView selectAnnotation:self.annotation animated:YES];
    }
}

- (void)loadData {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - Getters and setters
- (LLTitleSwitchCellView *)switchView {
    if (!_switchView) {
        _switchView = [[LLTitleSwitchCellView alloc] init];
        _switchView.backgroundColor = [LLThemeManager shared].containerColor;
        _switchView.title = @"Mock Location";
        [_switchView needLine];
    }
    return _switchView;
}

- (LLDetailTitleSelectorCellView *)locationDescriptView {
    if (!_locationDescriptView) {
        _locationDescriptView = [[LLDetailTitleSelectorCellView alloc] init];
        _locationDescriptView.backgroundColor = [LLThemeManager shared].containerColor;
        _locationDescriptView.title = @"Lat & Lng";
        _locationDescriptView.detailTitle = @"0, 0";
        [_locationDescriptView needFullLine];
    }
    return _locationDescriptView;
}

- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        _mapView.delegate = self;
    }
    return _mapView;
}

- (LLAnnotation *)annotation {
    if (!_annotation) {
        _annotation = [[LLAnnotation alloc] init];
    }
    return _annotation;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

@end
