rm-ivar-concurrency
===================

Demo of how RubyMotion ivar sets/gets are not atomic. The app simply runs 10 concurrent threads all setting and getting a single ivar as quickly as possible.  If you run this in the simulator for a few seconds, it should crash with various backtraces (often involving memory management).  E.g.:

```
$ rake debug=1
     Build ./build/iPhoneSimulator-7.1-Development
    Create ./build/iPhoneSimulator-7.1-Development/ivar-thread.app/Info.plist
  Simulate ./build/iPhoneSimulator-7.1-Development/ivar-thread.app
DYLD_FRAMEWORK_PATH="/Applications/Xcode.app/Contents/Developer/../Frameworks":"/Applications/Xcode.app/Contents/Developer/../OtherFrameworks" /Library/RubyMotion/bin/ios/sim 1 1 "iPhone Retina (4-inch)" 7.1 "/Applications/Xcode.app/Contents/Developer" "./build/iPhoneSimulator-7.1-Development/ivar-thread.app" 
starting test
Executing commands in '/var/folders/j3/6n4txds13kb70hklkw70r2040000gn/T/_simgdbcmds_ios'.
(lldb)  process attach -p 25867
Process 25867 stopped
Executable module set to "/usr/lib/dyld".
Architecture set to: i486-apple-macosx.
(lldb)  command script import /Library/RubyMotion/lldb/lldb.py
(lldb)  breakpoint set --name rb_exc_raise
Breakpoint 1: no locations (pending).
WARNING:  Unable to resolve breakpoint to any actual locations.
(lldb)  breakpoint set --name malloc_error_break
Breakpoint 2: no locations (pending).
WARNING:  Unable to resolve breakpoint to any actual locations.
(lldb)  continue
Process 25867 resuming
Process 25867 stopped
1 location added to breakpoint 1
1 location added to breakpoint 2
(lldb) bt
* thread #1: tid = 0x8246f4, 0x031eef7a libsystem_kernel.dylib`mach_msg_trap + 10, queue = 'com.apple.main-thread'
  * frame #0: 0x031eef7a libsystem_kernel.dylib`mach_msg_trap + 10
    frame #1: 0x031ee16c libsystem_kernel.dylib`mach_msg + 68
    frame #2: 0x01de9d69 CoreFoundation`__CFRunLoopServiceMachPort + 169
    frame #3: 0x01def35d CoreFoundation`__CFRunLoopRun + 1341
    frame #4: 0x01dee9d3 CoreFoundation`CFRunLoopRunSpecific + 467
    frame #5: 0x01dee7eb CoreFoundation`CFRunLoopRunInMode + 123
    frame #6: 0x03b055ee GraphicsServices`GSEventRunModal + 192
    frame #7: 0x03b0542b GraphicsServices`GSEventRun + 104
    frame #8: 0x005fef9b UIKit`UIApplicationMain + 1225
    frame #9: 0x00002f2c ivar-thread`main(argc=1, argv=0xbfffecf8) + 156 at main.mm:15
(lldb) c
Process 25867 resuming
Process 25867 stopped
* thread #6: tid = 0x8247ab, 0x001e20b2 libobjc.A.dylib`objc_msgSend + 14, queue = 'com.apple.root.default-priority', stop reason = EXC_BAD_ACCESS (code=1, address=0x322e302e)
    frame #0: 0x001e20b2 libobjc.A.dylib`objc_msgSend + 14
libobjc.A.dylib`objc_msgSend + 14:
-> 0x1e20b2:  movzwl 0xc(%edx), %eax
   0x1e20b6:  andl   %ecx, %eax
   0x1e20b8:  shll   $0x3, %eax
   0x1e20bb:  addl   0x8(%edx), %eax
(lldb) bt
* thread #6: tid = 0x8247ab, 0x001e20b2 libobjc.A.dylib`objc_msgSend + 14, queue = 'com.apple.root.default-priority', stop reason = EXC_BAD_ACCESS (code=1, address=0x322e302e)
  * frame #0: 0x001e20b2 libobjc.A.dylib`objc_msgSend + 14
    frame #1: 0x001e357b libobjc.A.dylib`objc_object::sidetable_release_slow((anonymous namespace)::SideTable*, bool) + 175
    frame #2: 0x001e363f libobjc.A.dylib`objc_object::sidetable_release(bool) + 185
    frame #3: 0x001e4aeb libobjc.A.dylib`-[NSObject release] + 25
    frame #4: 0x00003d43 ivar-thread`vm_ivar_set + 387
    frame #5: 0x0000cbbf ivar-thread`rb_scope__do_set__(self=0x0a07f0c0) + 415 at app_delegate.rb:27
    frame #6: 0x00131a1d ivar-thread`dispatch_rimp_caller(objc_object* (*)(objc_object*, objc_selector*, ...), unsigned long, objc_selector, int, unsigned long const*) + 46445
    frame #7: 0x0011843a ivar-thread`rb_vm_dispatch + 6554
    frame #8: 0x0000451c ivar-thread`vm_dispatch + 1100
    frame #9: 0x0000c918 ivar-thread`rb_scope__run_test__block__(self=0x0a07f0c0) + 264 at app_delegate.rb:17
    frame #10: 0x0012630b ivar-thread`dispatch_bimp_caller(objc_object* (*)(objc_object*, objc_selector*, ...), unsigned long, objc_selector, unsigned long, rb_vm_block*, int, unsigned long const*) + 46507
    frame #11: 0x00119731 ivar-thread`vm_block_eval(RoxorVM*, rb_vm_block*, objc_selector*, unsigned long, int, unsigned long const*) + 1137
    frame #12: 0x00119abd ivar-thread`rb_vm_yield_args + 77
    frame #13: 0x0010ec95 ivar-thread`loop_i + 101
    frame #14: 0x0013cccb ivar-thread`rb_rescue2 + 27
    frame #15: 0x0010e760 ivar-thread`rb_f_loop + 80
    frame #16: 0x00131a1d ivar-thread`dispatch_rimp_caller(objc_object* (*)(objc_object*, objc_selector*, ...), unsigned long, objc_selector, int, unsigned long const*) + 46445
    frame #17: 0x0011843a ivar-thread`rb_vm_dispatch + 6554
    frame #18: 0x0000451c ivar-thread`vm_dispatch + 1100
    frame #19: 0x0000c7cd ivar-thread`rb_scope__run_test__block__(self=0x0a07f0c0) + 173 at app_delegate.rb:15
    frame #20: 0x0012630b ivar-thread`dispatch_bimp_caller(objc_object* (*)(objc_object*, objc_selector*, ...), unsigned long, objc_selector, unsigned long, rb_vm_block*, int, unsigned long const*) + 46507
    frame #21: 0x00119731 ivar-thread`vm_block_eval(RoxorVM*, rb_vm_block*, objc_selector*, unsigned long, int, unsigned long const*) + 1137
    frame #22: 0x00119298 ivar-thread`rb_vm_block_eval + 104
    frame #23: 0x00100053 ivar-thread`rb_gcd_block_dispatcher + 51
    frame #24: 0x02e884d0 libdispatch.dylib`_dispatch_client_callout + 14
    frame #25: 0x02e76eb7 libdispatch.dylib`_dispatch_root_queue_drain + 291
    frame #26: 0x02e77127 libdispatch.dylib`_dispatch_worker_thread2 + 39
    frame #27: 0x031b7dab libsystem_pthread.dylib`_pthread_wqthread + 336
```
