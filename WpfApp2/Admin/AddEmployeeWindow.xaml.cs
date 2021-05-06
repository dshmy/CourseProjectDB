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
    /// Логика взаимодействия для AddEmployeeWindow.xaml
    /// </summary>
    public partial class AddEmployeeWindow : Window
    {
        public AddEmployeeWindow()
        {
            InitializeComponent();
            positionText.Items.Add("Продавец-консультант");
            positionText.Items.Add("Администратор");
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            try
                {
                    using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.adminConn))
                    {
                        connection.Open();

                        OracleParameter surname = new OracleParameter
                        {
                            ParameterName = "in_surname",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = surnameText.Text
                        };
                        OracleParameter name = new OracleParameter
                        {
                            ParameterName = "in_name",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = nameText.Text
                        };
                        OracleParameter secondname = new OracleParameter
                        {
                            ParameterName = "in_secondname",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = secondnameText.Text
                        };
                        OracleParameter login = new OracleParameter
                        {
                            ParameterName = "in_login",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = loginText.Text
                        };
                        OracleParameter password = new OracleParameter
                        {
                            ParameterName = "in_password",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = passwordText.Password
                        };
                        OracleParameter position = new OracleParameter
                        {
                            ParameterName = "in_password",
                            Direction = ParameterDirection.Input,
                            OracleDbType = OracleDbType.NVarchar2,
                            Value = positionText.Text
                        };

                        using (OracleCommand command = new OracleCommand("addEmployee",connection))
                        {
                            command.CommandType = CommandType.StoredProcedure;
                            command.Parameters.AddRange(new OracleParameter[] {name,surname,secondname,login,password,position});
                            command.ExecuteNonQuery();
                            MessageBox.Show("Пользователь добавлен успешно");
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