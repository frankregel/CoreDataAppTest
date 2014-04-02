//
//  Postleitzahl.h
//  CoreDataAppTest
//
//  Created by Frank Regel on 26.03.14.
//  Copyright (c) 2014 Frank Regel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Postleitzahl : NSManagedObject

@property (nonatomic, retain) NSString * plz;
@property (nonatomic, retain) NSSet *persons;
@end

@interface Postleitzahl (CoreDataGeneratedAccessors)

- (void)addPersonsObject:(Person *)value;
- (void)removePersonsObject:(Person *)value;
- (void)addPersons:(NSSet *)values;
- (void)removePersons:(NSSet *)values;

@end
