import 'package:flutter/material.dart';
import 'package:zenon_syrius_wallet_flutter/utils/app_colors.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/main_app_container.dart';
import 'package:zenon_syrius_wallet_flutter/widgets/modular_widgets/settings_widgets/display.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

// Dimensions
const double kAmountSuffixHeight = 25.0;
const double kAmountSuffixWidth = 40.0;
const double kAmountSuffixRadius = 5.0;
const double kContentPadding = 8.0;
const double kSeedWordCellWidth = 200.0;
const double kPasswordInputFieldWidth = 360.0;

// Size widgets
const Size kLoadingButtonMinSize = Size(120.0, 40.0);
const Size kSettingsButtonMinSize = Size(100.0, 35.0);
const SizedBox kVerticalSpacing = SizedBox(
  height: 15.0,
);
const SizedBox kSpacingBetweenActionButtons = SizedBox(
  width: 70.0,
);
const Size kAcceleratorProgressBarSize = Size(300.0, 10.0);

const List<String> kBridgeNetworks = [
  'BNB Smart Chain Mainnet',
];

// Wallet version
const String kWalletVersion = '0.0.5';

// Boxes constants
const String kFavoriteTokensBox = 'favourite_tokens_box';
const String kAddressesBox = 'addresses_box';
const String kAddressLabelsBox = 'address_labels_box';
const String kNotificationsBox = 'notifications_box';
const String kRecipientAddressBox = 'recipient_address_box';
const String kSharedPrefsBox = 'shared_prefs_box';
const String kNodesBox = 'nodes_box';
const String kKeyStoreBox = 'key_store_box';
const String kHtlcSwapsBox = 'htlc_swaps_box';
const String kLastCheckedHtlcBlockBox = 'last_checked_htlc_block_box';

const List<String> kCacheBoxesToBeDeleted = [
  kFavoriteTokensBox,
  kAddressesBox,
  kAddressLabelsBox,
  kNotificationsBox,
  kRecipientAddressBox,
  kSharedPrefsBox,
  kNodesBox,
  kHtlcSwapsBox,
  kLastCheckedHtlcBlockBox
];

// Swap temporary directory
const String kSwapWalletTempDirectory = 'swap-wallet';

// Wallet file name
const String kNameWalletFile = 'wallet';

// Github Syrius releases link
const String kGithubReleasesLink =
    'https://github.com/zenon-network/syrius/releases/latest';

const String kIncorrectPasswordNotificationTitle = 'Incorrect password';
const String kUnlockFailedNotificationTitle = 'Unlock failed';
const String kDefaultDateFormat = 'dd MMMM, yyyy';
const String kDefaultDateTimeFormat = 'yyyy-MM-dd hh:mm a';

// Key-value store
const String kTextScalingKey = 'text_scaling_key';
const String kSelectedNodeKey = 'selected_node_key';
const String kDefaultAddressKey = 'default_address';
const String kWalletVersionKey = 'wallet_version_key';
const String kNumUnlockFailedAttemptsKey = 'num_unlock_failed_attempts';
const String kEntropyFilePathKey = 'entropy_file_path_key';
const String kWindowSizeWidthKey = 'window_size_width_key';
const String kWindowSizeHeightKey = 'window_size_height_key';
const String kWindowPositionXKey = 'window_position_x_key';
const String kWindowPositionYKey = 'window_position_y_key';
const String kWindowMaximizedKey = 'window_maximized_key';
const String kP2pSwapsKey = 'p2p_swaps_key';
const String kP2pAtomicUnlockKey = 'p2p_atomic_unlock_key';
const String kP2pAutoReclaimKey = 'p2p_auto_reclaim_key';
const String kLastCheckedHtlcBlockKey = 'last_checked_htlc_block_key';

const double kDefaultBorderOutlineWidth = 1.0;
const double kMinDelegationAmount = 1.0;
const double kStandardChartNumDays = 7;
const double kMinTokenTotalMaxSupply = 1;

const int kMaxInt = 9223372036854775807;
const int kAddressLabelMaxLength = 80;
const int kNumOfInitialAddresses = 1;
const int kSeedGridNumOfRows = 4;
const int kNumOfSeedWordsToBeFound = 6;
const int kNumOfChartLeftSideTitles = 10;
const int kOneHourInSeconds = 3600;
const int kMomentumsPerHour = kOneHourInSeconds ~/ kSecondsPerMomentum;
const int kHoursPerDay = 24;
const int kMomentumsPerDay = kHoursPerDay * kMomentumsPerHour;
const int kDaysInAWeek = 7;
const int kMomentumsPerWeek = kMomentumsPerDay * kDaysInAWeek;
const int kNumOfAddresses = 10;
const int kPillarPlasmaAmountNeeded = 252000;
const int kSentinelPlasmaAmountNeeded = 252000;
const int kStakePlasmaAmountNeeded = 105000;
const int kDelegatePlasmaAmountNeeded = 84000;
const int kIssueTokenPlasmaAmountNeeded = 189000;
const int kZnnProjectMaximumFunds = 5000;
const int kQsrProjectMaximumFunds = 50000;
const int kZnnProjectMinimumFunds = 10;
const int kQsrProjectMinimumFunds = 100;
const int kAmountInputMaxCharacterLength = 21;
const int kSecondsPerMomentum = 10;

const List<int> kNormalUsersPlasmaRequirements = [
  kStakePlasmaAmountNeeded,
  kDelegatePlasmaAmountNeeded,
];
const List<int> kPowerUsersPlasmaRequirements = [
  kPillarPlasmaAmountNeeded,
  kSentinelPlasmaAmountNeeded,
  kIssueTokenPlasmaAmountNeeded,
];

const String kLocalhostDefaultNodeUrl = 'ws://127.0.0.1:35998';

List<String> kDefaultNodes = [
  'Embedded Node',
  kLocalhostDefaultNodeUrl,
];
const List<String> kWalletActions = [
  'pillar',
  'sentinel',
  'delegation',
  'stake',
  'plasma',
];

// Notifications constants
const int kNotificationsResultLimit = 100;
const int kNotificationsEntriesLimit = 10000;
const String kNotificationsTimeFormat = 'hh:mm aaa';
const int kWalletNotificationHiveTypeId = 100;
const int kNotificationTypeEnumHiveTypeId = 101;

// Community links
const String kWebsite = 'zenon.network';
const String kCommunityWebsite = 'zenon.community';
const String kOrgCommunityWebsite = 'zenon.org';
const String kTwitter = 'twitter.com/Zenon_Network';
const String kTelegram = 't.me/joinchat/MLyPehLIbJj1nw1XOOOltg';
const String kGithub = 'github.com/zenon-network';
const String kExplorer = 'explorer.zenon.network';
const String kScraper = 'zenonscraper.com';
const String kWiki = 'github.com/zenon-network/znn-wiki';
const String kCommunityWiki = 'zenon.wiki';
const String kTools = 'zenon.tools';
const String kZnnController = 'github.com/zenon-network/znn_controller_dart';
const String kBitcoinTalk =
    'bitcointalk.org/index.php?topic=5279643.msg55303681#msg55303681';
const String kDiscord = 'discord.gg/VE2ENBGPNa';
const String kMedium = 'medium.com/@zenon.network';
const String kReddit = 'reddit.com/r/Zenon_Network';
const String kYoutube = 'youtube.com/channel/UCDb8ZtqBt6l5l4HugCnJwhQ';

// Bridge links
const String kJoinLiquidityProgramUrl =
    'https://bridge.zenon.network/#liquidity';
const String kAddLiquidityUrl =
    'https://pancakeswap.finance/add/0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c/0x84b174628911896a3b87fa6980d05dbc2ee74836';
const int kLiquidityRewardsMultiplier = 10;

// Wallet security
const double kAutoEraseNumAttemptsDefault = 3;
const int kAutoLockWalletDefaultIntervalMinutes = 15;
const String kAutoLockWalletMinutesKey = 'auto_lock_interval_minutes';
const String kAutoEraseNumAttemptsKey = 'auto_erase_num_attempts';

// Display constants
const String kThemeModeKey = 'theme_mode_key';
const ThemeMode kDefaultThemeMode = ThemeMode.dark;
const TextScaling kDefaultTextScaling = TextScaling.system;

const kBlockTypeColorMap = {
  BlockTypeEnum.userReceive: AppColors.darkHintTextColor,
  BlockTypeEnum.userSend: AppColors.lightHintTextColor,
};

// Duration constants
const Duration kDelayAfterAccountBlockCreationCall = Duration(
  seconds: 31,
);
const Duration kProjectVotingPeriod = Duration(days: 14);
const Duration kEmbeddedConnectionDelay = Duration(seconds: 30);

// Tabs
const List<Tabs> kTabsWithTextTitles = [
  Tabs.dashboard,
  Tabs.transfer,
  Tabs.pillars,
  Tabs.sentinels,
  Tabs.staking,
  Tabs.plasma,
  Tabs.tokens,
  Tabs.p2pSwap,
];

const List<Tabs> kTabsWithIconTitles = [
  Tabs.bridge,
  Tabs.accelerator,
  Tabs.help,
  Tabs.notifications,
  Tabs.settings,
  Tabs.resyncWallet,
  Tabs.lock,
];

const List<Tabs> kDisabledTabs = [
  Tabs.resyncWallet,
];
