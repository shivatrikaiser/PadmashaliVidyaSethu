# Tests

* `Backend/PadmashaliVidyaSetu.Api.Tests` - xUnit unit tests and API integration tests (in-process API + throw-away LocalDB database). Run: `dotnet test Backend/PadmashaliVidyaSetu.slnx`.
* Flutter unit/widget tests: `Frontend/padmashali_vidya_setu/test` (`flutter test`).
* End-to-end: `Frontend/padmashali_vidya_setu/integration_test` (emulator + running API).

**Windows: keep the clone path short.** The integration tests load SQL Server's native driver
(`Microsoft.Data.SqlClient.SNI.dll`) from the test `bin` folder. If the repository sits in a deeply nested folder, that
path passes Windows' 260-character limit and every integration test fails with `DllNotFoundException ... The filename
or extension is too long`. Clone to a short path (e.g. `D:\Projects\PVS`) or enable long paths
(`git config --system core.longpaths true` and the `LongPathsEnabled` registry setting).
