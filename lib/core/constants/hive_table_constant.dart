class HelpDeskTableConstant {
  
  // Private constructor to prevent instantiation
  HelpDeskTableConstant._();

  static const String dbName = 'community_help_desk_db';

  static const int reportTypeId = 7;
  static const String reportTable = 'report_table';

  static const int ticketTypeId = 0;
  static const String ticketTable = 'ticket_table';

  static const int userTypeId = 1;
  static const String userTable = 'user_table';
  
  static const int roleTypeId = 2;
  static const String roleTable = 'role_table';

  static const int articleTypeId = 3;
  static const String articleTable = 'article_table';

  static const int categoryTypeId = 5;
  static const String categoryTable = 'category_table';

  static const int preferenceTypeId = 6;
  static const String preferenceTable = 'preference_table';
}