import 'dart:developer';

import 'package:flutter/foundation.dart';

const String red = '\x1B[31m';
const String green = '\x1B[32m';
const String yellow = '\x1B[33m';
const String blue = '\x1B[34m';
const String magenta = '\x1B[35m';
const String reset = '\x1B[0m';
const String white = '\x1B[37m';

void errorLog(
  dynamic message, {
  String name = 'ERROR',
  String funtionName = "GENERAL",
}) {
  if(kDebugMode) {
    log("$red$message$reset", name: name);
  }
}

void generalLog(
  dynamic message, {
  String name = 'GENERAL',
  String funtionName = "GENERAL",
}) {
  if(kDebugMode) {
  log("$yellow$message$reset", name: name);
  }
}

void screenLog(
  dynamic message, {
  String name = 'SCREEN',
  String funtionName = "SCREEN",
}) {
  if(kDebugMode) {
    log("$white$message$reset", name: name);
  }
}

void cubitLog(
  dynamic message, {
  String name = 'CUBIT',
  String funtionName = "CUBIT",
}) {
  if(kDebugMode) {
    log("$magenta$message$reset", name: name);
  }
}

void repositoryLog(
  dynamic message, {
  String name = 'REPOSITORY',
  String funtionName = "REPOSITORY",
}) {
  if(kDebugMode) {
    log("$green$message$reset", name: name);
  }
}