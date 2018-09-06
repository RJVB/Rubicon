//
//  main.m
//  TypeSizes
//
//  Created by Galen Rhodes on 9/6/18.
//  Copyright © 2018 Project Galen. All rights reserved.
//

#import <Rubicon/Rubicon.h>

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSUInteger len = 15;
        PGPrintf(@"+%@+----+\n", [@"" stringByPaddingToLength:len + 2 withString:@"-" startingAtIndex:0]);
        PGPrintf(@"| %@ |Size|\n", [@"Data Type" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0]);
        PGPrintf(@"+%@+----+\n", [@"" stringByPaddingToLength:len + 2 withString:@"-" startingAtIndex:0]);
        PGPrintf(@"| %@ | %2zu |\n", [@"char" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(char));
        PGPrintf(@"| %@ | %2zu |\n", [@"short" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(short));
        PGPrintf(@"| %@ | %2zu |\n", [@"int" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(int));
        PGPrintf(@"| %@ | %2zu |\n", [@"long" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(long));
        PGPrintf(@"| %@ | %2zu |\n", [@"long long" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(long long));
        PGPrintf(@"| %@ | %2zu |\n", [@"float" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(float));
        PGPrintf(@"| %@ | %2zu |\n", [@"double" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(double));
        PGPrintf(@"| %@ | %2zu |\n", [@"long double" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(long double));
        PGPrintf(@"+%@+----+\n", [@"" stringByPaddingToLength:len + 2 withString:@"-" startingAtIndex:0]);
    }
    return 0;
}
