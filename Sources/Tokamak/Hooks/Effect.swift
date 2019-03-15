//
//  Effect.swift
//  Tokamak
//
//  Created by Max Desiatov on 10/02/2019.
//

extension Hooks {
  /// Schedule an effect to be executed on every call to `render`.
  public func effect(closure: @escaping () -> ()) {
    scheduleEffect(nil) { closure(); return nil }
  }

  /** Schedule an effect to be executed on every call to `render`. The effect
   closure should return a cleanup closure to be executed before the next
   call to `render` or when a component is unmounted.
   */
  public func finalizedEffect(closure: @escaping () -> () -> ()) {
    scheduleEffect(nil, closure)
  }

  /** Schedule an effect to be executed on calls to `render` when `observed`
   value has changed from the previous call to `render`.

   You can use this overload of `effect` to control when exactly the effect
   `closure` is executed. For example, always pass `Null()` as `observed` so
   that the effect is executed only once on the initial rendering.

   Another use case is an effect that schedules a repeated timer with a specific
   interval. You wouldn't want to reschedule the timer on every call to
   component's `render` if the interval hasn't changed. Pass the interval as
   `observed`, which will be compared to the previous value and trigger effect
   execution (updating the timer interval or creating a new timer) when the
   interval has changed.
   */
  public func effect<T: Equatable>(_ observed: T, closure: @escaping () -> ()) {
    scheduleEffect(AnyEquatable(observed)) { closure(); return nil }
  }

  /** Schedule an effect to be executed on calls to `render` when `observed`
   value has changed from the previous call to `render`. The effect
   closure should return a cleanup closure to be executed before the next
   call to `render` or when a component is unmounted.

   You can use this overload of `effect` to control when exactly the effect
   `closure` is executed with additional cleanup. For example, always pass
   `Null()` as `observed` so that the effect is executed only once on the
   initial rendering.

   Another use case is an effect that subscribes to updates on a user model
   fetched from the network and you need to correctly unsubscribe from updates
   when a component is unmounted. You wouldn't to unsubscribe and resubscribe
   every time a component rerendered if an observed user ID hasn't changed.
   Pass the ID as `observed`, which will be compared to the previous value and
   trigger effect execution (unsubscribing from updates on old user ID and
   subscribing for new user ID) when the ID has changed.
   */
  public func finalizedEffect<T>(
    _ observed: T,
    closure: @escaping () -> () -> ()
  )
    where T: Equatable {
    scheduleEffect(AnyEquatable(observed), closure)
  }
}
