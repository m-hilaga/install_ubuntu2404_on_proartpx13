;;; 
(defun mor-header ()
  "Inserts a header template."
  (interactive)
  (let ((name (upcase (replace-regexp-in-string "\\." "_" (buffer-name)))))
    (insert (format "#ifndef %s
#define %s
#ifdef __cplusplus
extern \"C\" {
#endif


#ifdef __cplusplus
} /* extern \"C\" { */
#endif
#endif /* #ifndef %s */
"                  
                    name name name))))


;;;
(defun mor-class-h (name)
  "Inserts a class decralation in a C header."
  (interactive "sInput class name (default Class): ")
  (progn
    (if (equal name "") (setq name 'Class))
    (insert (format "/******************************************************************
 * mor_%s
 ******************************************************************/


/** @struct mor_%s
 */
typedef struct mor_%s_tag {
    mor_Env *env;
} mor_%s;


/** Constructs.
 * @memberof mor_%s */
MOR_EXTERN
mor_Result
mor_construct_%s(mor_%s *self, mor_Env *env);


/** Destructs.
 * @memberof mor_%s */
#ifdef MOR_DOXYGEN
mor_Result mor_destruct_%s(mor_%s *self);
#else
#define mor_destruct_%s mor_%s_cleanup
#endif


/** Creates.
 * @memberof mor_%s */
#ifdef MOR_DOXYGEN
mor_%s *mor_create_%s(mor_Env *env);
#else
#define mor_create_%s(env) MOR_CREATE(env, %s)
#endif


/** Destroys.
 * @memberof mor_%s */
#ifdef MOR_DOXYGEN
mor_Result mor_destroy_%s(mor_Env *env, mor_%s *self);
#else
#define mor_destroy_%s(env,self) MOR_DESTROY(env, %s, self)
#endif


/** Initializes with default parameters.
 * @memberof mor_%s */
#ifdef MOR_DOXYGEN
mor_Result mor_%s_initialize(mor_%s *self);
#else
#define mor_%s_initialize(self) mor_%s_init(self)
#endif


/** Initializes.
 * @memberof mor_%s */
MOR_EXTERN
mor_Result
mor_%s_init(mor_%s *self);


/** Cleans up.
 * @memberof mor_%s */
MOR_EXTERN
mor_Result
mor_%s_cleanup(mor_%s *self);


/** Gets the environment.
 * @memberof mor_%s */
#ifdef MOR_DOXYGEN
mor_Env *mor_%s_getEnv(const mor_%s *self);
#else
#define mor_%s_getEnv(self) ((self)->env)
#endif


"
                   name name name name name name name name name name
                   name name name name name name name name name name
                   name name name name name name name name name name
                   name name name name name name name))))


;;;
(defun mor-class-c (name)
  "Inserts a class definition in a C source."
  (interactive "sInput class name (default Class): ")
  (progn
    (if (equal name "") (setq name 'Class))
    (insert (format "
/******************************************************************
 * mor_%s
 ******************************************************************/


mor_Result
mor_construct_%s(mor_%s *self, mor_Env *env)
{
    mor_Result ret = MOR_OK;

    self->env = env;

    return ret;
}


mor_Result
mor_%s_init(mor_%s *self)
{
    mor_Result ret = MOR_OK;

    ret |= mor_%s_cleanup(self);

    return ret;
}


mor_Result
mor_%s_cleanup(mor_%s *self)
{
    mor_Result ret = MOR_OK;

    return ret;
}
"
                  name name name name name name name name))))


;;;
(defun mor-test ()
  "Inserts a test code template."
  (interactive)
  (insert "#include \"mor_env.h\"
#include \"mor_scope.h\"
#include <stdio.h>
#include <stdlib.h>
#if MOR_SPEC_CORE_HEAP == 1
#define BUFFER_SIZE (1024*1024*256)
#else
#define BUFFER_SIZE (0)
#endif


int
main(int argc, char **argv)
{
    mor_Result ret = MOR_OK;
#if MOR_SPEC_CORE_HEAP == 1
    mor_Uint8 *buffer = (mor_Uint8*)malloc(BUFFER_SIZE);
#else
    mor_Uint8 *buffer = NULL;
#endif
    mor_Env *env = mor_create_Env(buffer, BUFFER_SIZE);

    ret |= mor_Env_setLogFunc(env, fprintf, stdout);

    MOR_BEGIN_SCOPE(s, env) {
      
    } MOR_END_SCOPE(s);

    ret |= mor_destroy_Env(env);
    if(buffer) {
        free(buffer);
    }
    return ret;
}
"))
