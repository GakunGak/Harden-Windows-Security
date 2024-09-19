
#nullable enable

// Used by WDAC Simulations
namespace WDACConfig
{
    public class SimulationInput(System.IO.FileInfo filepath, WDACConfig.ChainPackage[] allfilesigners, WDACConfig.Signer[] signerinfo, string[] ekuoids)
    {
        // Adding public getters and setters for the properties
        public System.IO.FileInfo FilePath { get; set; } = filepath;
        public WDACConfig.ChainPackage[] AllFileSigners { get; set; } = allfilesigners;
        public WDACConfig.Signer[] SignerInfo { get; set; } = signerinfo;
        public string[] EKUOIDs { get; set; } = ekuoids;
    }
}
