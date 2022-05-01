class PersianDateUtil {
  static String now([int format]) {
    if (format == null) format = 1;
    return formatDateTime(DateTime.now(), 1);
  }

  static String formatDateTime(DateTime inputDate, int format) {
    String _output = "";
    switch (format) {
      case 0:
        _output = inputDate.hour.toString() +
            ":" +
            inputDate.minute.toString() +
            ":" +
            inputDate.second.toString();
        break;
      case 1:
        _output = inputDate.year.toString().padLeft(2, '0') +
            "/" +
            inputDate.month.toString().padLeft(2, '0') +
            "/" +
            inputDate.day.toString().padLeft(2, '0') +
            "  " +
            inputDate.hour.toString().padLeft(2, '0') +
            ":" +
            inputDate.minute.toString().padLeft(2, '0') +
            ":" +
            inputDate.second.toString().padLeft(2, '0');
        break;
      case 2:
        _output = inputDate.year.toString().padLeft(2, '0') +
            "/" +
            inputDate.month.toString().padLeft(2, '0') +
            "/" +
            inputDate.day.toString().padLeft(2, '0') +
            "  " +
            inputDate.hour.toString().padLeft(2, '0') +
            ":" +
            inputDate.minute.toString().padLeft(2, '0');
        break;
      case 3:
        _output = inputDate.hour.toString().padLeft(2, '0') +
            ":" +
            inputDate.minute.toString().padLeft(2, '0');

        break;
      case 4:
        _output = inputDate.hour.toString().padLeft(2, '0') +
            ":" +
            inputDate.minute.toString().padLeft(2, '0') +
            ":" +
            inputDate.second.toString().padLeft(2, '0');

        break;
      default:
        _output = "?";
    }

    return _output;
  }

  static String DayOfWeek(DateTime Gr_Date) {
    String strOut = "_";
    switch (Gr_Date.weekday) {
      case 6:
        strOut = "شنبه";
        break;
      case 7:
        strOut = "یکشنبه";
        break;
      case 1:
        strOut = "دوشنبه";
        break;
      case 2:
        strOut = "سه شنبه";
        break;
      case 3:
        strOut = "چهارشنبه";
        break;
      case 4:
        strOut = "پنجشنبه";
        break;
      case 5:
        strOut = "جمعه";
        break;
    }
    return (strOut);
  }

  static String PersianMonthName(int Persian_Month) {
    switch (Persian_Month) {
      case 1:
        return "فروردین";
      case 2:
        return "اردیبهشت";
      case 3:
        return "خرداد";
      case 4:
        return "تیر";
      case 5:
        return "مرداد";
      case 6:
        return "شهریور";
      case 7:
        return "مهر";
      case 8:
        return "آبان";
      case 9:
        return "آذر";
      case 10:
        return "دی";
      case 11:
        return "بهمن";
      case 12:
        return "اسفند";
      default:
        return "";
    }
  }

  static bool IsLeapYear(int Persian_Year) {
    int Remind = Persian_Year % 33;
    return (Remind == 1 ||
        Remind == 5 ||
        Remind == 9 ||
        Remind == 13 ||
        Remind == 18 ||
        Remind == 22 ||
        Remind == 26 ||
        Remind == 30);
  }

  static String MItoSH_Full(DateTime Gr_Date) {
    String output = "";
    try {
      output += DayOfWeek(Gr_Date);
      output += " " + MItoSH(Gr_Date) + " ";
      output += Gr_Date.hour.toString().padLeft(2, '0') +
          ":" +
          Gr_Date.minute.toString().padLeft(2, '0');
    } catch (exn) {}
    return output;
  }

  static String MItoSH_yymmdd_hhmm(DateTime Gr_Date) {
    String output = "";
    try {
      output += MItoSH(Gr_Date) + " ";
      output += Gr_Date.hour.toString() + ":" + Gr_Date.minute.toString();
    } catch (exn) {}
    return output;
  }

  // ignore: non_constant_identifier_names
  static String MItoSH(DateTime Gr_Date) {
    // ignore: non_constant_identifier_names
    List<int> MDay = [];

    MDay.insert(0, 31);
    MDay.insert(1, 31);
    MDay.insert(2, 31);
    MDay.insert(3, 31);
    MDay.insert(4, 30);
    MDay.insert(5, 31);
    MDay.insert(6, 31);
    MDay.insert(6, 30);
    MDay.insert(7, 31);
    MDay.insert(8, 31);
    MDay.insert(9, 30);
    MDay.insert(10, 31);
    MDay.insert(11, 30);
    MDay.insert(12, 31);
    int ED = Gr_Date.day;
    int EM = Gr_Date.month;
    int EY = Gr_Date.year;
    int IY;
    int IM;
    int IDAYS;
    int ID;
    if (EY % 4 == 0)
      MDay[2] = 29;
    else
      MDay[2] = 28;

    int EDAYS = ED;
    if (EM > 1) for (int I = 1; I < EM; I++) EDAYS = EDAYS + MDay[I];

    if (EDAYS < 80) {
      IY = EY - 622;
      IDAYS = EDAYS + 286;
      if (IY % 4 == 3) IDAYS = IDAYS + 1;
    } else {
      IY = EY - 621;
      IDAYS = EDAYS - 79;
    }
    ID = IDAYS;
    if (IDAYS <= 186)
      for (IM = 0; ID > 31; IM++) {
        if (ID > 30) ID = ID - 31;
      }
    else {
      ID = ID - 186;
      for (IM = 6; ID > 30; IM++) {
        ID = ID - 30;
      }
    }

    IM = IM + 1;

    String strOut =
        IY.toString().padLeft(4) + "/" + IM.toString() + "/" + ID.toString();

    return (strOut);
  }

  // ignore: non_constant_identifier_names
  static DateTime SHtoMI(String Sh_Date) {
    bool VALID_IRIDATE;
    DateTime Output = new DateTime(1900, 1, 1);
    int IDAYS, EY = 0, EDAYS = 0, ED = 0, EM = 0;
    List<int> MDay = [];

    MDay.insert(0, 31);
    MDay.insert(1, 31);
    MDay.insert(2, 31);
    MDay.insert(3, 31);
    MDay.insert(4, 30);
    MDay.insert(5, 31);
    MDay.insert(6, 31);
    MDay.insert(6, 30);
    MDay.insert(7, 31);
    MDay.insert(8, 31);
    MDay.insert(9, 30);
    MDay.insert(10, 31);
    MDay.insert(11, 30);
    MDay.insert(12, 31);

    try {
      String strBuffer = Sh_Date.substring(0, Sh_Date.indexOf("/"));
      int IY = int.parse(strBuffer);
      Sh_Date = Sh_Date.substring(Sh_Date.indexOf("/") + 1);

      strBuffer = Sh_Date.substring(0, Sh_Date.indexOf("/"));
      int IM = int.parse(strBuffer);
      Sh_Date = Sh_Date.substring(Sh_Date.indexOf("/") + 1);
      //strBuffer = Sh_Date.substring(0, Sh_Date.indexOf(" "));

      int ID = int.parse(Sh_Date);
      VALID_IRIDATE = true;
      if (IM < 7 && ID > 31) VALID_IRIDATE = false;
      if (7 < IM && IM < 11 && ID > 30) VALID_IRIDATE = false;
      if (IM == 12) if ((IY % 4 == 3 && ID > 30) || (IY % 4 != 3 && ID > 29))
        VALID_IRIDATE = false;
      if (IM > 12 || IM < 1) VALID_IRIDATE = false;
      if (!VALID_IRIDATE) return (DateTime.parse("1900-01-01 00:00:00"));

      if (IM <= 7)
        IDAYS = 31 * IM + ID - 31;
      else
        IDAYS = 30 * IM + ID - 24;

      int IKBS = IY % 4;
      if (IKBS == 3 && IDAYS <= 287) {
        EY = IY + 621;
        EDAYS = IDAYS + 79;
      } else if (IKBS == 3 && IDAYS > 287) {
        EY = IY + 622;
        EDAYS = IDAYS - 287;
      } else if (IKBS != 3 && IDAYS <= 286) {
        EY = IY + 621;
        EDAYS = IDAYS + 79;
      } else if (IKBS != 3 && IDAYS > 286) {
        EY = IY + 622;
        EDAYS = IDAYS - 286;
      }

      if (EY % 4 == 0)
        MDay[2] = 29;
      else
        MDay[2] = 28;

      ED = EDAYS;
      bool LoopEnd = false;
      for (EM = 1; EM < 13 && !LoopEnd; EM++) {
        if (ED <= MDay[EM])
          LoopEnd = true;
        else
          ED = ED - MDay[EM];
      }
      EM--;
      strBuffer = EY.toString() +
          "-" +
          EM.toString().padLeft(2, '0') +
          "-" +
          ED.toString().padLeft(2, '0') +
          " 00:00:00";
      Output = DateTime.parse(strBuffer); // "1900-01-01 00:00:00")
      return (Output);
    } catch (exp) {
      return (DateTime.parse("1900-01-01 00:00:00"));
    }
  }
}
