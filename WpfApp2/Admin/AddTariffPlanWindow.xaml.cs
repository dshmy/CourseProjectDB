using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using Oracle.ManagedDataAccess.Client;
using WpfApp2.DataBase;

namespace WpfApp2.Admin
{
    /// <summary>
    /// Логика взаимодействия для AddTariffPlanWindow.xaml
    /// </summary>
    public partial class AddTariffPlanWindow : Window
    {
        public AddTariffPlanWindow()
        {
            InitializeComponent();
        }

        private void addTariffPlanButton_Click(object sender, RoutedEventArgs e)
        {
            if (tariffNameText.Text == String.Empty || priceText.Text == String.Empty || double.Parse(priceText.Text) <= 0)
                MessageBox.Show("Проверьте введенные данные");
            else
                try
                {
                    using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.adminConn))
                    {
                        string unl = "безлимит";
                        connection.Open();

                        OracleParameter tariffPlan = new OracleParameter
                        {
                            ParameterName = "in_name",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = tariffNameText.Text
                        };
                        OracleParameter price = new OracleParameter
                        {
                            ParameterName = "in_price",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.Decimal,
                            Value = decimal.Parse(priceText.Text)
                        };
                        OracleParameter minutes = new OracleParameter
                        {
                            ParameterName = "in_mins",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = minutesText.Text
                        };
                        OracleParameter sms = new OracleParameter
                        {
                            ParameterName = "in_sms",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = smsText.Text
                        };
                        OracleParameter mms = new OracleParameter
                        {
                            ParameterName = "in_mms",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = mmsText.Text
                        };
                        OracleParameter megabytes = new OracleParameter
                        {
                            ParameterName = "in_megabytes",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = megabytesText.Text
                        };
                        if (minutesText.Text == String.Empty && unlimMinutesCheck.IsChecked.Value == false)
                            minutes.Value = null;
                        if (smsText.Text == String.Empty && unlimSMSCheck.IsChecked.Value == false)
                            sms.Value = null;
                        if (mmsText.Text == String.Empty && unlimMMSCheck.IsChecked.Value == false)
                            mms.Value = null;
                        if (megabytesText.Text == String.Empty && unlimMegabytesCheck.IsChecked.Value == false)
                            megabytes.Value = null;
                        if (unlimMinutesCheck.IsChecked.Value)
                        minutes.Value = unl;
                        if (unlimSMSCheck.IsChecked.Value)
                        sms.Value = unl;
                        if (unlimMMSCheck.IsChecked.Value)
                        mms.Value = unl;
                        if (unlimMegabytesCheck.IsChecked.Value)
                        megabytes.Value = unl;

                        using (OracleCommand command = new OracleCommand("addTariffPlan", connection))
                        {
                            command.CommandType = CommandType.StoredProcedure;
                            command.Parameters.AddRange(new OracleParameter[] { tariffPlan, price, minutes, sms, mms, megabytes });
                            command.ExecuteNonQuery();
                            MessageBox.Show("Тариф добавлен успешно");
                        }
                    }
                }
                catch (OracleException ex)
                {
                    MessageBox.Show(ex.Message);

                }
        }
    }
}
