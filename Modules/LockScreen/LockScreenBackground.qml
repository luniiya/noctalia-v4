import QtQuick
import Quickshell
import qs.Commons

Item {
  id: root
  anchors.fill: parent

  required property var screen

  // Wallpapers are drawn by the system wallpaper daemon, not the shell
  Rectangle {
    anchors.fill: parent
    color: "#000000"
  }

  Rectangle {
    anchors.fill: parent
    gradient: Gradient {
      GradientStop {
        position: 0.0
        color: Qt.alpha(Color.mShadow, 0.4)
      }
      GradientStop {
        position: 0.3
        color: Qt.alpha(Color.mShadow, 0.2)
      }
      GradientStop {
        position: 0.7
        color: Qt.alpha(Color.mShadow, 0.25)
      }
      GradientStop {
        position: 1.0
        color: Qt.alpha(Color.mShadow, 0.5)
      }
    }
  }

  // Screen corners for lock screen
  Item {
    anchors.fill: parent
    visible: Settings.data.general.showScreenCorners

    property color cornerColor: Settings.data.general.forceBlackScreenCorners ? "black" : Color.mSurface
    property real cornerRadius: Style.screenRadius
    property real cornerSize: Style.screenRadius

    // Top-left concave corner
    Canvas {
      anchors.top: parent.top
      anchors.left: parent.left
      width: parent.cornerSize
      height: parent.cornerSize
      antialiasing: true
      renderTarget: Canvas.FramebufferObject
      smooth: false

      onPaint: {
        const ctx = getContext("2d");
        if (!ctx)
          return;
        ctx.reset();
        ctx.clearRect(0, 0, width, height);

        ctx.fillStyle = parent.cornerColor;
        ctx.fillRect(0, 0, width, height);

        ctx.globalCompositeOperation = "destination-out";
        ctx.fillStyle = "#ffffff";
        ctx.beginPath();
        ctx.arc(width, height, parent.cornerRadius, 0, 2 * Math.PI);
        ctx.fill();
      }

      onWidthChanged: if (available)
                        requestPaint()
      onHeightChanged: if (available)
                         requestPaint()
    }

    // Top-right concave corner
    Canvas {
      anchors.top: parent.top
      anchors.right: parent.right
      width: parent.cornerSize
      height: parent.cornerSize
      antialiasing: true
      renderTarget: Canvas.FramebufferObject
      smooth: true

      onPaint: {
        const ctx = getContext("2d");
        if (!ctx)
          return;
        ctx.reset();
        ctx.clearRect(0, 0, width, height);

        ctx.fillStyle = parent.cornerColor;
        ctx.fillRect(0, 0, width, height);

        ctx.globalCompositeOperation = "destination-out";
        ctx.fillStyle = "#ffffff";
        ctx.beginPath();
        ctx.arc(0, height, parent.cornerRadius, 0, 2 * Math.PI);
        ctx.fill();
      }

      onWidthChanged: if (available)
                        requestPaint()
      onHeightChanged: if (available)
                         requestPaint()
    }

    // Bottom-left concave corner
    Canvas {
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      width: parent.cornerSize
      height: parent.cornerSize
      antialiasing: true
      renderTarget: Canvas.FramebufferObject
      smooth: true

      onPaint: {
        const ctx = getContext("2d");
        if (!ctx)
          return;
        ctx.reset();
        ctx.clearRect(0, 0, width, height);

        ctx.fillStyle = parent.cornerColor;
        ctx.fillRect(0, 0, width, height);

        ctx.globalCompositeOperation = "destination-out";
        ctx.fillStyle = "#ffffff";
        ctx.beginPath();
        ctx.arc(width, 0, parent.cornerRadius, 0, 2 * Math.PI);
        ctx.fill();
      }

      onWidthChanged: if (available)
                        requestPaint()
      onHeightChanged: if (available)
                         requestPaint()
    }

    // Bottom-right concave corner
    Canvas {
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      width: parent.cornerSize
      height: parent.cornerSize
      antialiasing: true
      renderTarget: Canvas.FramebufferObject
      smooth: true

      onPaint: {
        const ctx = getContext("2d");
        if (!ctx)
          return;
        ctx.reset();
        ctx.clearRect(0, 0, width, height);

        ctx.fillStyle = parent.cornerColor;
        ctx.fillRect(0, 0, width, height);

        ctx.globalCompositeOperation = "destination-out";
        ctx.fillStyle = "#ffffff";
        ctx.beginPath();
        ctx.arc(0, 0, parent.cornerRadius, 0, 2 * Math.PI);
        ctx.fill();
      }

      onWidthChanged: if (available)
                        requestPaint()
      onHeightChanged: if (available)
                         requestPaint()
    }
  }
}
