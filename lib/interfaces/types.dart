﻿import 'package:flutter/material.dart';

typedef TRouterData = ({String route, String name, IconData icon});
typedef TActionData = ({String name, VoidCallback call, IconData icon});
typedef TIconData = ({String name, IconData icon});
typedef TLinkData = ({String name, String link});
typedef TJsonMap = Map<String, dynamic>;
typedef TMap<T> = Map<String, T>;
typedef TMaps<T> = Map<String, TMap<T>>;
typedef TChangeCallback<T, F> = T Function(F value);
typedef TChangeValue<T> = TChangeCallback<T, T>;
typedef TSpanMatch = ({RegExp reg, TChangeCallback<TextSpan, Match> match});