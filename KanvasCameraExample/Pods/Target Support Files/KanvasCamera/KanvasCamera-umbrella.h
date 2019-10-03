#ifdef __OBJC__
#import <UIKit/UIKit.h>

@import OpenGLES;
@import GLKit;
GLfloat * GL_GLKMatrix4Pointer(GLKMatrix4 * matrix);
void GL_glUniformMatrix4fv(GLint location, GLint count, GLint s, GLKMatrix4 * matrix);

#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

FOUNDATION_EXPORT double KanvasCameraVersionNumber;
FOUNDATION_EXPORT const unsigned char KanvasCameraVersionString[];

