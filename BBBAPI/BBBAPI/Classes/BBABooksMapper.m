//
//  BBABooksResponseMapper.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 11/12/2014.
  

#import "BBABooksMapper.h"
#import "BBABookItem.h"
#import "BBAImageItem.h"
#import "BBALinkItem.h"
#import <NSArray+Functional.h>
#import <FastEasyMapping.h>

static NSString *const kBookSchema = @"urn:blinkboxbooks:schema:book";


@interface BBABooksMapper ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) FEMObjectMapping *linksMapping;
@end

@implementation BBABooksMapper

#pragma mark - Getters

- (NSDateFormatter *) dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _dateFormatter;
}

- (FEMObjectMapping *) linksMapping{
    if (!_linksMapping) {
        _linksMapping = [BBALinkItem linkItemMapping];
    }
    return _linksMapping;
}

#pragma mark - Public

- (BBABookItem *) itemFromDictionary:(NSDictionary *)dictionary{
    
    BOOL classIsOk = [dictionary isKindOfClass:[NSDictionary class]];
    NSParameterAssert(classIsOk);
    if (!classIsOk) {
        return nil;
    }
    
    NSString *type = dictionary[@"type"];
    NSParameterAssert([type isEqualToString:kBookSchema]);
    if (![type isEqualToString:kBookSchema]) {
        return nil;
    }
    
    BBABookItem *item = [BBABookItem new];
    item.title = dictionary[@"title"];
    item.guid = dictionary[@"guid"];
    item.identifier = dictionary[@"id"];
    NSString *publicationDate = dictionary[@"publicationDate"];
    
    item.sampleEligible = [dictionary[@"sampleEligible"] boolValue];
    
    if (publicationDate) {
        item.publicationDate = [self.dateFormatter dateFromString:publicationDate];
    }
    
    [self mapImages:dictionary[@"images"] toItem:item];
    
    NSArray *links = dictionary[@"links"];
    
    item.links = [FEMObjectDeserializer deserializeCollectionExternalRepresentation:links
                                                                       usingMapping:self.linksMapping];
    
    return item;
}

#pragma mark - Private

- (void) mapImages:(NSArray *)array toItem:(BBABookItem *)item{
    BOOL parameterOk = [array isKindOfClass:[NSArray class]] || array != nil;
    NSParameterAssert(parameterOk);
    if (!parameterOk) {
        return;
    }
    
    NSMutableArray *images = [NSMutableArray new];
    for (NSDictionary *imageDict in array) {
        
        BBAImageItem *image = [BBAImageItem new];
        image.url = [NSURL URLWithString:imageDict[@"src"]];
        image.relative = imageDict[@"rel"];
        [images addObject:image];
    }
    
    item.images = images;
    
}

@end
