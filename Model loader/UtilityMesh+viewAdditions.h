//utf-8;134217984esh+viewAdditions.h
//  
//

#import "UtilityMesh.h"

@interface UtilityMesh (viewAdditions)

- (void)prepareToDraw;
- (void)prepareToPick;
- (void)drawCommandsInRange:(NSRange)aRange;
- (void)drawBoundingBoxStringForCommandsInRange:
   (NSRange)aRange;

@end
