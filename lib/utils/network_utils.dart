class NetworkUtils {
  static bool checkAddress(String address) {

    List<String> parts = address.split(":");
    if (parts.length != 2) {
      return false;
    }

    if (parts[0].isEmpty || parts[1].isEmpty) {
      return false;
    }

    if (parts[0].split(".").length != 4) {
      return false;
    }

    if (int.tryParse(parts[1]) == null) {
      return false;
    }

    for (String part in parts[0].split(".")) {
      if (int.tryParse(part) == null || int.parse(part) < 0 || int.parse(part) > 255) {
        return false;
      }
    }
    return true;
  }
}