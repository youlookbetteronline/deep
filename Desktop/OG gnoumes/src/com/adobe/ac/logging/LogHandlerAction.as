package com.adobe.ac.logging
{
    import mx.logging.ILogger;
    import mx.logging.Log;

    public class LogHandlerAction implements GlobalExceptionHandlerAction
    {
        private static const LOG:ILogger = Log.getLogger("UncaughtException");

        public function handle(error:Object):void
        {
            if (error is Error)
            {
                var errorObj:Error = error as Error;

                LOG.error("{0}. {1}\n {2}",
                          errorObj.errorID,
                          errorObj.message,
                          errorObj.getStackTrace());
            }
        }
    }
}