//
//  BBASuggestionItem.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/01/2015.
  

#import "BBASuggestionItem.h"
#import <FastEasyMapping/FastEasyMapping.h>

@interface BBASuggestionItem ()
@property (nonatomic, copy) NSString *serverType;
@end

@implementation BBASuggestionItem

+ (FEMObjectMapping *) objectMapping{
    FEMObjectMapping *mapping;
    mapping = [FEMObjectMapping mappingForClass:[BBASuggestionItem class]
                                            configuration:^(FEMObjectMapping *mapping) {
                                                [mapping addAttribute:[FEMAttribute mappingOfProperty:@"title"
                                                                                            toKeyPath:@"title"]];
                                                [mapping addAttribute:[FEMAttribute mappingOfProperty:@"serverType"
                                                                                            toKeyPath:@"type"]];
                                                [mapping addAttribute:[FEMAttribute mappingOfProperty:@"identifier"
                                                                                            toKeyPath:@"id"]];
                                                [mapping addAttribute:[FEMAttribute mappingOfProperty:@"authors"
                                                                                            toKeyPath:@"authors"]];
                                            }];
    return mapping;
}

- (BBASuggestionType)type{
    /* 
     TODO:
     Horrible hack for server containing duplicate keys for 'type'
     Ticket PT-649 is tracking server side fix for duplicate 'type' field
     */
    if ([[self serverType] isEqualToString:@"urn:blinkboxbooks:schema:suggestion:book"] ||
        [[self serverType] isEqualToString:@"bookSuggestionRepresentation"]) {
        return BBASuggestionTypeBook;
    }
    else if ([[self serverType] isEqualToString:@"urn:blinkboxbooks:schema:suggestion:contributor"] ||
             [[self serverType] isEqualToString:@"authorSuggestionRepresentation"]) {
        return BBASuggestionTypeAuthor;
    }

    return BBASuggestionTypeBook;
}
@end
