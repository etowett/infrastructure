def jobView(
  String viewName,
  String searchRegex
) {
  listView(viewName.toUpperCase()) {
    jobs {
      regex(searchRegex)
    }
    columns {
      status()
      weather()
      name()
      lastSuccess()
      lastFailure()
      lastDuration()
      buildButton()
    }
  }
}

def appView(
  String appName
) {
  jobView("${appName}", /${appName}-.*/)
}

def filterView(
  String appName
) {
  jobView("${appName}", /.*${appName}.*/)
}

// filterView("PG")
