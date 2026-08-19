import 'package:flutter/material.dart';

/// Global route observer used to refresh screens when they become visible
/// again — e.g. the exams list after a nested exam-taking flow ends, or the
/// video player after a lesson exam closes.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
