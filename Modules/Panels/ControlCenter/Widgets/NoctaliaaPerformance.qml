import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Power
import qs.Widgets

NIconButtonHot {
  property ShellScreen screen

  icon: PowerProfileService.noctaliaaPerformanceMode ? "rocket" : "rocket-off"
  tooltipText: I18n.tr("tooltips.noctaliaa-performance-enabled")
  hot: PowerProfileService.noctaliaaPerformanceMode
  onClicked: PowerProfileService.toggleNoctaliaaPerformance()
}
