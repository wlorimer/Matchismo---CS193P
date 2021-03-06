//
//  GameViewController.m
//  Matchismo
//
//  Created by Ashley Robinson on 05/08/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "GameViewController.h"
#import "GameResult.h"

@interface GameViewController ()

@end

@implementation GameViewController

- (void)setFlipCount:(int)flipCount
{
    _flipCount = flipCount;
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", flipCount];
}

- (void)setCardButtons:(NSArray *)cardButtons
{
    _cardButtons = cardButtons;
    [self updateUI];
}

- (NSMutableArray *)history {
    if (!_history) {
        _history = [[NSMutableArray alloc] init];
    }
    return _history;
}

- (CardMatchingGame *)game
{
    return nil; // needs to be implemented in sub class
}

- (GameResult *)gameResult
{
    if (!_gameResult) _gameResult = [[GameResult alloc] init];
    return _gameResult;
}

- (GameSettings *)gameSettings
{
    if (!_gameSettings) _gameSettings = [[GameSettings alloc] init];
    return _gameSettings;
}

- (void)updateUI
{
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
    self.resultOfLastFlipLabel.alpha = 1;
    self.resultOfLastFlipLabel.text = self.game.descriptionOfLastFlip;
    
    [self updateSliderRange];
}

- (void)updateSliderRange
{
    int maxValue = [self.history count] - 1;
    if (maxValue < 0) maxValue = 0;
    self.historySlider.maximumValue = maxValue;
    [self.historySlider setValue:maxValue animated:YES];
}

- (IBAction)flipCard:(UIButton *)sender
{
    self.cardModeSelector.enabled = NO;
    [self.game flipCardAtIndex:[self.cardButtons indexOfObject:sender]];
    self.flipCount++;
    
    if (![[self.history lastObject] isEqualToString:self.game.descriptionOfLastFlip])
        [self.history addObject:self.game.descriptionOfLastFlip];
    
    self.gameResult.score = self.game.score;
    
    [self updateUI];
}

- (IBAction)dealButtonPressed:(UIButton *)sender {
    self.game = nil;
    self.flipCount = 0;
    self.cardModeSelector.enabled = YES;
    self.history = nil;
    self.gameResult = nil;
    [self updateUI];
}

- (IBAction)cardModeChanged:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            self.game.numberOfMatchingCards = 2;
            break;
        case 1:
            self.game.numberOfMatchingCards = 3;
            break;
        default:
            self.game.numberOfMatchingCards = 2;
            break;
    }
}

- (IBAction)historySliderChanged:(UISlider *)sender {
    int sliderValue;
    sliderValue = lroundf(self.historySlider.value);
    [self.historySlider setValue:sliderValue animated:NO];
    
    if ([self.history count]) {
        self.resultOfLastFlipLabel.alpha = (sliderValue + 1 < [self.history count]) ? 0.6 : 1.0;
        self.resultOfLastFlipLabel.attributedText = [self UpdateText:[self.history objectAtIndex:sliderValue]];
    }
}

- (NSMutableAttributedString *)UpdateText:(NSString *)message
{
    return [[NSMutableAttributedString alloc] initWithString:message];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.game.matchBonus = self.gameSettings.matchBonus;
    self.game.mismatchPenalty = self.gameSettings.mismatchPenalty;
    self.game.flipCost = self.gameSettings.flipCost;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
}

@end
