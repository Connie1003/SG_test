USE master
GO

IF TYPE_ID('FILELIST_ONLY') IS NOT NULL
BEGIN DROP TYPE FILELIST_ONLY END
GO

IF TYPE_ID('HEADER_ONLY') IS NOT NULL
BEGIN DROP TYPE HEADER_ONLY END
GO

CREATE TYPE FILELIST_ONLY AS TABLE
(
	[LogicalName]			NVARCHAR(128),
	[PhysicalName]			NVARCHAR(260),
	[Type]					CHAR(1),
	[FileGroupName]			NVARCHAR(128),
	[Size]					NUMERIC(20,0),
	[MaxSize]				NUMERIC(20,0),
	[FileID]				BIGINT,
	[CreateLSN]				NUMERIC(25,0),
	[DropLSN]				NUMERIC(25,0),
	[UniqueID]				UNIQUEIDENTIFIER,
	[ReadOnlyLSN]			NUMERIC(25,0),
	[ReadWriteLSN]			NUMERIC(25,0),
	[BackupSizeInBytes]		BIGINT,
	[SourceBlockSize]		INT,
	[FileGroupID]			INT,
	[LogGroupGUID]			UNIQUEIDENTIFIER,
	[DifferentialBaseLSN]	NUMERIC(25,0),
	[DifferentialBaseGUID]	UNIQUEIDENTIFIER,
	[IsReadOnly]			BIT,
	[IsPresent]				BIT,
	[TDEThumbprint]			VARBINARY(32),
	[SnapshotUrl]			NVARCHAR(360)
)
GO

CREATE TYPE HEADER_ONLY AS TABLE
(
	BackupName				NVARCHAR(128),
	BackupDescription		NVARCHAR(255),
	BackupType				SMALLINT,
	ExpirationDate			DATETIME,
	Compressed				BIT,
	Position				SMALLINT,
	DeviceType				TINYINT,
	UserName				NVARCHAR(128),
	ServerName				NVARCHAR(128),
	DatabaseName			NVARCHAR(128),
	DatabaseVersion			INT,
	DatabaseCreationDate	DATETIME,
	BackupSize				NUMERIC(20, 0),
	FirstLSN				NUMERIC(25, 0),
	LastLSN					NUMERIC(25, 0),
	CheckpointLSN			NUMERIC(25, 0),
	DatabaseBackupLSN		NUMERIC(25, 0),
	BackupStartDate			DATETIME,
	BackupFinishDate		DATETIME,
	SortOrder				SMALLINT,
	[CodePage]				SMALLINT,
	UnicodeLocaleId			INT,
	UnicodeComparisonStyle	INT,
	CompatibilityLevel		TINYINT,
	SoftwareVendorId		INT,
	SoftwareVersionMajor	INT,
	SoftwareVersionMinor	INT,
	SoftwareVersionBuild	INT,
	MachineName				NVARCHAR(128),
	Flags					INT,
	BindingId				UNIQUEIDENTIFIER,
	RecoveryForkId			UNIQUEIDENTIFIER,
	Collation				NVARCHAR(128),
	FamilyGUID				UNIQUEIDENTIFIER,
	HasBulkLoggedData		BIT,
	IsSnapshot				BIT,
	IsReadOnly				BIT,
	IsSingleUser			BIT,
	HasBackupChecksums		BIT,
	IsDamaged				BIT,
	BeginsLogChain			BIT,
	HasIncompleteMetaData	BIT,
	IsForceOffline			BIT,
	IsCopyOnly				BIT,
	FirstRecoveryForkID		UNIQUEIDENTIFIER,
	ForkPointLSN			NUMERIC(25, 0),
	RecoveryModel			NVARCHAR(60),
	DifferentialBaseLSN		NUMERIC(25, 0),
	DifferentialBaseGUID	UNIQUEIDENTIFIER,
	BackupTypeDescription	NVARCHAR(60),
	BackupSetGUID			UNIQUEIDENTIFIER,
	CompressedBackupSize	BIGINT,
	[Containment]			TINYINT,
	KeyAlgorithm			NVARCHAR(32),
	EncryptorThumbprint		VARBINARY(20),
	EncryptorType			NVARCHAR(32)
	--2022額外欄位
	--,LastValidRestoreTime	DATETIME
	--,TimeZone				NVARCHAR(32)
	--,CompressionAlgorithm	NVARCHAR(32)
)
GO