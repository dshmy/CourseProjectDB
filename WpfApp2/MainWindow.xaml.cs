using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using Oracle.ManagedDataAccess.Client;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Drawing;
using WpfApp2.DataBase;
using WpfApp2.Users;
using WpfApp2.Admin;
using WpfApp2.Client;
using WpfApp2.Employee;

namespace WpfApp2
{
    /// <summary>
    /// Логика взаимодействия для MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public OracleConnection oracleConnection;
        public CurrentEmployee currentEmployee;
        public CurrentClient currentClient;
        public string adminPos = "Администратор";
        public string employeePos = "Продавец-консультант";
        public bool check = false;
        public MainWindow()
        {
            InitializeComponent();
        }

        private void registrationButton_Click(object sender, RoutedEventArgs e)
        {
            RegistrationWindow rw = new RegistrationWindow();
            rw.ShowDialog();
        }

        private void loginButton_Click(object sender, RoutedEventArgs e)
        {
            currentEmployee = new CurrentEmployee();
            currentClient = new CurrentClient();
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.adminConn))
                {
                    connection.Open();

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
                    OracleParameter user = new OracleParameter
                    {
                        ParameterName = "user_cur",
                        Direction = ParameterDirection.Output,
                        OracleDbType = OracleDbType.RefCursor
                    };
                    if (!loginText.Text.StartsWith("+37533"))
                    {
                        using (OracleCommand command = new OracleCommand("findUser",connection))
                        {
                            command.CommandType = CommandType.StoredProcedure;
                            command.Parameters.AddRange(new OracleParameter[] {login, password, user});
                            var reader = command.ExecuteReader();
                            DataTable dt = new DataTable();
                            dt.Load(reader);

                            foreach (DataRow row in dt.Rows)
                            {
                                check = true;
                                currentEmployee.id = int.Parse(row["Id"].ToString());
                                currentEmployee.position = row["Position"].ToString();
                            }
                        }
                        connection.Close();
                        if (adminPos == currentEmployee.position)
                        {
                            AdminWindow adminWindow = new AdminWindow();
                            adminWindow.Show();
                            this.Close();
                        }

                        if (employeePos == currentEmployee.position)
                        {
                            CreateContractWindow createContractWindow = new CreateContractWindow(currentEmployee);
                            createContractWindow.Show();
                            this.Close();
                        }
                    }
                    else
                    {
                        using (OracleCommand command = new OracleCommand("findClient"))
                        {
                            command.Connection = connection;
                            command.CommandType = CommandType.StoredProcedure;
                            command.Parameters.AddRange(new OracleParameter[] { login, password, user });
                            var reader = command.ExecuteReader();
                            DataTable dt = new DataTable();
                            dt.Load(reader);

                            foreach (DataRow row in dt.Rows)
                            {
                                check = true;
                                currentClient.id = int.Parse(row["Id"].ToString());
                            }
                            connection.Close();
                            ClientWindow clientWindow = new ClientWindow(currentClient);
                            clientWindow.Show();
                            this.Close();
                        }

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
