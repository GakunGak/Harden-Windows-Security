using Microsoft.UI.Xaml.Controls;

namespace WDACConfig.Pages
{
    public sealed partial class CreatePolicy : Page
    {
        public CreatePolicy()
        {
            this.InitializeComponent();

            // Make sure navigating to/from this page maintains its state
            this.NavigationCacheMode = Microsoft.UI.Xaml.Navigation.NavigationCacheMode.Enabled;
        }
    }
}
