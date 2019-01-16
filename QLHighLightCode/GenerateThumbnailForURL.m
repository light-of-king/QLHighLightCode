#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "PreviewHTML.h"

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef request, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    // To complete your generator please implement the function GenerateThumbnailForURL in GenerateThumbnailForURL.c
    if (QLThumbnailRequestIsCancelled(request)) return noErr;
    
    NSURL *file_url = (__bridge NSURL *)(url);
    NSString *_thumbnail = [PreviewHTML render:file_url];
    NSDictionary *properties = @{
                                 (id)kQLThumbnailPropertyExtensionKey: [(__bridge NSURL*)url pathExtension]
                                 };
    QLThumbnailRequestSetThumbnailWithDataRepresentation(request,(__bridge CFDataRef)[_thumbnail dataUsingEncoding:NSUTF8StringEncoding],kUTTypeHTML,NULL,(__bridge CFDictionaryRef)(properties));
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
