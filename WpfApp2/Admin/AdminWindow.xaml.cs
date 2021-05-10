using System;
using System.Collections.Generic;
using System.ComponentModel;
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
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using Oracle.ManagedDataAccess.Client;
using WpfApp2.DataBase;
using WpfApp2.Users;

namespace WpfApp2.Admin
{
    /// <summary>
    /// Логика взаимодействия для AdminWindow.xaml
    /// </summary>
    public partial class AdminWindow : Window
    {
        private Tariffs tars;
        public BindingList<Tariffs> tarsList = new BindingList<Tariffs>();
        private CurrentEmployee empl;
        public BindingList<CurrentEmployee> emplList = new BindingList<CurrentEmployee>();
        public AdminWindow()
        {
            InitializeComponent();
            GetEmployees();
            employees.ItemsSource = emplList;
            GetTars();
            tarsDG.ItemsSource = tarsList;
        }

        private void addEmployee_Click(object sender, RoutedEventArgs e)
        {
            AddEmployeeWindow addEmployee = new AddEmployeeWindow();
            addEmployee.Show();
        }

        private void addTariffPlan_Click(object sender, RoutedEventArgs e)
        {
            AddTariffPlanWindow addTariffPlanWindow = new AddTariffPlanWindow();
            addTariffPlanWindow.Show();
        }

        private void exit_Click(object sender, RoutedEventArgs e)
        {
            MainWindow main = new MainWindow();
            main.Show();
            this.Close();
        }

        private void GetTars()
        {
            tarsList.Clear();
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.adminConn))
                {
                    connection.Open();
                    OracleParameter curs = new OracleParameter
                    {
                        ParameterName = "curs",
                        Direction = ParameterDirection.Output,
                        OracleDbType = OracleDbType.RefCursor,
                    };

                    using (OracleCommand command = new OracleCommand("getTar"))
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] { curs });
                        var reader = command.ExecuteReader();
                        DataTable dt = new DataTable();
                        dt.Load(reader);

                        foreach (DataRow row in dt.Rows)
                        {
                            tars = new Tariffs(row["Name"].ToString(), row["Price"].ToString());
                            tarsList.Add(tars);
                        }
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void GetEmployees()
        {
            emplList.Clear();
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.adminConn))
                {
                    connection.Open();
                    OracleParameter curs = new OracleParameter
                    {
                        ParameterName = "curs",
                        Direction = ParameterDirection.Output,
                        OracleDbType = OracleDbType.RefCursor,
                    };

                    using (OracleCommand command = new OracleCommand("getEmployees"))
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] { curs });
                        var reader = command.ExecuteReader();
                        DataTable dt = new DataTable();
                        dt.Load(reader);

                        foreach (DataRow row in dt.Rows)
                        {
                           empl = new CurrentEmployee(row["Surname"].ToString(), row["Name"].ToString(),
                                row["SecondName"].ToString(), row["Position"].ToString());
                            emplList.Add(empl);
                        }
                    
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
           
        }

        private void Window_Activated(object sender, EventArgs e)
        {
            emplList.Clear();
            tarsList.Clear();
            GetTars();
            tarsDG.ItemsSource = tarsList;
            GetEmployees();
            employees.ItemsSource = emplList;
        }
    }
}