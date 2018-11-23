//
// Book:      OpenGL(R) ES 2.0 Programming Guide
// Authors:   Aaftab Munshi, Dan Ginsburg, Dave Shreiner
// ISBN-10:   0321502795
// ISBN-13:   9780321502797
// Publisher: Addison-Wesley Professional
// URLs:      http://safari.informit.com/9780321563835
//            http://www.opengles-book.com
//

// Simple_TextureCubemap.c
//
//    This is a simple example that draws a sphere with a cubemap image applied.
//
#include <stdlib.h>
#include "esUtil.h"

typedef struct
{
   // Handle to a program object
   GLuint programObject;

   // Attribute locations
   GLint  positionLoc;
   GLint  normalLoc;

   // Sampler location
   GLint samplerLoc;
    
    GLint mvp;

   // Texture handle
   GLuint textureId;

   // Vertex data
   int      numIndices;
   GLfloat *vertices;
   GLfloat *normals;
   GLushort *indices;

} UserData;

///
// Create a simple cubemap with a 1x1 face with a different
// color for each face
void CreateSimpleTextureCubemap( ESContext *esContext, UserData *userData)
{
    if (!userData->textureId) {
        glDeleteTextures(1, &(userData->textureId));
        userData->textureId = 0;
    }
    if (!userData->textureId) {
        GLuint textureId;
        // Generate a texture object
        glGenTextures ( 1, &textureId );
        userData->textureId = textureId;
    }
    
    if (esContext->textureData) {
        glBindTexture(GL_TEXTURE_2D, userData->textureId);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, esContext->textureWidth, esContext->height, 0, GL_RGBA, GL_UNSIGNED_BYTE, esContext->textureData);
    }else{
        // Bind the texture object
        glBindTexture ( GL_TEXTURE_CUBE_MAP, userData->textureId );
        // Six 1x1 RGB faces
        GLubyte cubePixels[6][3] =
        {
            // Face 0 - Red
            255, 0, 0,
            // Face 1 - Green,
            0, 255, 0,
            // Face 3 - Blue
            0, 0, 255,
            // Face 4 - Yellow
            255, 255, 0,
            // Face 5 - Purple
            255, 0, 255,
            // Face 6 - White
            255, 255, 255
        };
        // Load the cube face - Positive X
        glTexImage2D ( GL_TEXTURE_CUBE_MAP_POSITIVE_X, 0, GL_RGB, 1, 1, 0,
                      GL_RGB, GL_UNSIGNED_BYTE, &cubePixels[0] );
        
        // Load the cube face - Negative X
        glTexImage2D ( GL_TEXTURE_CUBE_MAP_NEGATIVE_X, 0, GL_RGB, 1, 1, 0,
                      GL_RGB, GL_UNSIGNED_BYTE, &cubePixels[1] );
        
        // Load the cube face - Positive Y
        glTexImage2D ( GL_TEXTURE_CUBE_MAP_POSITIVE_Y, 0, GL_RGB, 1, 1, 0,
                      GL_RGB, GL_UNSIGNED_BYTE, &cubePixels[2] );
        
        // Load the cube face - Negative Y
        glTexImage2D ( GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, GL_RGB, 1, 1, 0,
                      GL_RGB, GL_UNSIGNED_BYTE, &cubePixels[3] );
        
        // Load the cube face - Positive Z
        glTexImage2D ( GL_TEXTURE_CUBE_MAP_POSITIVE_Z, 0, GL_RGB, 1, 1, 0,
                      GL_RGB, GL_UNSIGNED_BYTE, &cubePixels[4] );
        
        // Load the cube face - Negative Z
        glTexImage2D ( GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, GL_RGB, 1, 1, 0,
                      GL_RGB, GL_UNSIGNED_BYTE, &cubePixels[5] );
        // Set the filtering mode
        glTexParameteri ( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
        glTexParameteri ( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    }
}

static void loadTextureData(ESContext *esContext, GLfloat textureWidth, GLfloat textureHeight, GLubyte *textureData){
    esContext->textureWidth = textureWidth;
    esContext->textureHeight = textureHeight;
    esContext->textureData = textureData;
    CreateSimpleTextureCubemap(esContext,(UserData *)esContext->userData);
}

///
// Initialize the shader and program object
//
int Init ( ESContext *esContext )
{
    esContext->updateTextureData = loadTextureData;
   esContext->userData = malloc(sizeof(UserData));
   UserData *userData = esContext->userData;
   GLbyte vShaderStr[] =  
      "attribute vec4 a_position;   \n"
      "attribute vec3 a_normal;     \n"
      "varying vec3 v_normal;       \n"
      "uniform  mat4 um4_ModelViewProjection; \n"
      "void main()                  \n"
      "{                            \n"
      "   gl_Position = um4_ModelViewProjection * a_position; \n"
      "   v_normal = a_normal;      \n"
      "}                            \n";
   
   GLbyte fShaderStr[] =  
      "precision mediump float;                            \n"
      "varying vec3 v_normal;                              \n"
      "uniform samplerCube s_texture;                      \n"
      "void main()                                         \n"
      "{                                                   \n"
      "  gl_FragColor = textureCube( s_texture, v_normal );\n"
      "}                                                   \n";

   // Load the shaders and get a linked program object
   userData->programObject = esLoadProgram ( vShaderStr, fShaderStr );

   // Get the attribute locations
   userData->positionLoc = glGetAttribLocation ( userData->programObject, "a_position" );
   userData->normalLoc = glGetAttribLocation ( userData->programObject, "a_normal" );
   
   // Get the sampler locations
   userData->samplerLoc = glGetUniformLocation ( userData->programObject, "s_texture" );

    // Get the mvp
    userData->mvp = glGetUniformLocation(userData->programObject, "um4_ModelViewProjection");
   // Load the texture
   CreateSimpleTextureCubemap (esContext,userData);

   // Generate the vertex data
   userData->numIndices = esGenSphere ( 200, 1.0f, &userData->vertices, &userData->normals,
                                        NULL, &userData->indices );

   
   glClearColor ( 0.0f, 0.0f, 0.0f, 0.0f );
   return GL_TRUE;
}

///
// Draw a triangle using the shader pair created in Init()
//
void Draw ( ESContext *esContext,GLfloat textureWidth, GLfloat textureHeight, GLubyte *textureData )
{
   UserData *userData = esContext->userData;
      
   // Set the viewport
   glViewport ( 0, 0, esContext->width, esContext->height );
   
   glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
   // Clear the color buffer
   glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

   glCullFace ( GL_BACK );
   glEnable ( GL_CULL_FACE );
   
   // Use the program object
   glUseProgram ( userData->programObject );
    
   // Load the vertex position
   glVertexAttribPointer ( userData->positionLoc, 3, GL_FLOAT, 
                           GL_FALSE, 0, userData->vertices );
   // Load the normal
   glVertexAttribPointer ( userData->normalLoc, 3, GL_FLOAT,
                           GL_FALSE, 0, userData->normals );

   glEnableVertexAttribArray ( userData->positionLoc );
   glEnableVertexAttribArray ( userData->normalLoc );

   // Bind the texture
   glActiveTexture ( GL_TEXTURE0 );
    if (esContext->textureData) {
        glBindTexture(GL_TEXTURE_2D, userData->textureId);
    }else {
        glBindTexture ( GL_TEXTURE_CUBE_MAP, userData->textureId );
    }

//    ESMatrix perspective;
//    esMatrixLoadIdentity( &perspective );
//    es
//    //    esPerspective(&perspective, 45, (GLfloat)esContext->width/(GLfloat)esContext->height, 0.1f, 100.0f);
////    esScale(&perspective, -1.0f, 1.0f, 1.0f);
//
//    ESMatrix modelViewMatrix;
//    esMatrixLoadIdentity( &modelViewMatrix );
////    float scale = 1.0f;
////    esScale(&modelViewMatrix, scale, scale, scale);
////    esTranslate(&modelViewMatrix, 0.0f, -1.0f, 0.0f);
////    esRotate(&modelViewMatrix, 30, 0.0f, 1.0f, 0.0f);
//
//    esRotate(&modelViewMatrix, esContext->degreeY, 1, 0, 0);
//    esRotate(&modelViewMatrix, esContext->degreeX, 0, 1, 0);
//
//    ESMatrix vMatrix;
//    esMatrixMultiply(&vMatrix, &perspective, &modelViewMatrix);
//
//    glUniformMatrix4fv(userData->mvp, 1, GL_FALSE, (const GLfloat *)&vMatrix.m);

    // setup view and projection matrices
    ESMatrix    view, proj, viewProj;

    // view matrix
    esMatrixLoadIdentity(&view);
    // build eye position vector
    GLfloat eyeX, eyeY, eyeZ;
    eyeX = 0.0f;
    eyeZ = 5.0f;
    eyeY = 0.0f;
    esLookAt(&view,    eyeX, eyeY, eyeZ,        0.0, 0.0, -3.0,        0, 1, 0);
    esRotate(&view, esContext->degreeY, 1, 0, 0);
    esRotate(&view, esContext->degreeX, 0, 1, 0);
    // projection matrix
    esMatrixLoadIdentity(&proj);
    esPerspective(&proj, 60.0f, (GLfloat)(esContext->width)/(GLfloat)(esContext->height), 0.1f, 1000.f);

    // view-proj
    esMatrixLoadIdentity(&viewProj);
    esMatrixMultiply(&viewProj, &view, &proj);
    float scale = 1.8f;
    esScale(&viewProj, scale, scale, scale);

    // model
    ESMatrix    model;
    esMatrixLoadIdentity(&model);
    
    // calculate and set model-view-proj matrix
    ESMatrix modelViewProj;
    esMatrixLoadIdentity(&modelViewProj);
    esMatrixMultiply(&modelViewProj, &model, &viewProj);

//    ESMatrix    modelUpsideDown;
//    esMatrixLoadIdentity(&modelUpsideDown);
//    esScale(&modelUpsideDown, 1.0, -1.0, 1.0);
//
//    ESMatrix modelViewProjUpsideDown;
//    esMatrixMultiply(&modelViewProjUpsideDown, &modelUpsideDown, &viewProj);
//    ESMatrix matrix;
//    esMatrixLoadIdentity(&matrix);
//    esOrtho(&matrix, -1.0f,1.0f, -1.8f, 1.8f, -1.0f, 1.0f );
    glUniformMatrix4fv(userData->mvp, 1, GL_FALSE, (const GLfloat *)&modelViewProj.m);
   // Set the sampler texture unit to 0
   glUniform1i ( userData->samplerLoc, 0 );

   glDrawElements ( GL_TRIANGLES, userData->numIndices, 
                    GL_UNSIGNED_SHORT, userData->indices );
}

///
// Cleanup
//
void ShutDown ( ESContext *esContext )
{
   UserData *userData = esContext->userData;

   // Delete texture object
   glDeleteTextures ( 1, &userData->textureId );

   // Delete program object
   glDeleteProgram ( userData->programObject );

   free ( userData->vertices );
   free ( userData->normals );
	
   free ( esContext->userData);
}
