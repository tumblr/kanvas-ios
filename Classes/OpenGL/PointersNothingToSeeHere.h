//
//  PointersNothingToSeeHere.h
//  KanvasCamera
//
//  Created by Jimmy Schementi on 9/30/19.
//

#ifndef PointersNothingToSeeHere_h
#define PointersNothingToSeeHere_h

@import OpenGLES;
@import GLKit;

GLfloat * GL_GLKMatrix4Pointer(GLKMatrix4 * matrix) {
    return (GLfloat*)matrix->m;
}

void GL_glUniformMatrix4fv(GLint location, GLint count, GLint s, GLKMatrix4 * matrix) {
    glUniformMatrix4fv(location, count, s, (GLfloat*)matrix->m);
}

#endif /* PointersNothingToSeeHere_h */
