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

namespace WpfApp2
{
    /// <summary>
    /// Логика взаимодействия для RegistrationWindow.xaml
    /// </summary>
    public partial class RegistrationWindow : Window
    {
        public RegistrationWindow()
        {
            InitializeComponent();
        }

        private void registrationButton_Click(object sender, RoutedEventArgs e)
        {
            if (passwordText.Password != passwordCheckText.Password)
                MessageBox.Show("Пароли не совпадают");
            else
                try
                {
                    using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.adminConn))
                    {
                        connection.Open();

                        OracleParameter number = new OracleParameter
                        {
                            ParameterName = "in_number",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = phoneNumberText.Text
                        };
                        OracleParameter passportnumber = new OracleParameter
                        {
                            ParameterName = "in_passportnumber",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = passportNumberText.Text
                        };
                        OracleParameter password = new OracleParameter
                        {
                            ParameterName = "in_password",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = passwordText.Password
                        };
                        using (OracleCommand command = new OracleCommand("registrationClient"))
                        {
                            command.Connection = connection;
                            command.CommandType = CommandType.StoredProcedure;
                            command.Parameters.AddRange(new OracleParameter[]
                            {
                                number, passportnumber, password
                            });
                            int r = command.ExecuteNonQuery();
                            MessageBox.Show("Регистрация прошла успешно");
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