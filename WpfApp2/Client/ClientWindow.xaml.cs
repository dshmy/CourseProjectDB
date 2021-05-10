using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
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
using Microsoft.Web.WebView2.Wpf;
using WpfApp2.DataBase;
using WpfApp2.Users;

namespace WpfApp2.Client
{
    /// <summary>
    /// Логика взаимодействия для ClientWindow.xaml
    /// </summary>
    public partial class ClientWindow : Window
    {
        private Thread thread;
        public float tr=0;
        public CurrentClient currentClient;
        static PerformanceCounterCategory performanceCounterCategory = new PerformanceCounterCategory("Network Interface");
        static string instance = performanceCounterCategory.GetInstanceNames()[1];
        PerformanceCounter performanceCounterSent = new PerformanceCounter("Network Interface", "Bytes Sent/sec", instance);
        PerformanceCounter performanceCounterReceived = new PerformanceCounter("Network Interface", "Bytes Received/sec", instance);

        public ClientWindow(CurrentClient cc)
        {
            InitializeComponent();
            
            currentClient = cc;
            this.Loaded += ClientWindow_Loaded;
        }

        private void currClientData()
        {
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.clientConn))
                {
                    connection.Open();

                    OracleParameter id = new OracleParameter
                    {
                        ParameterName = "in_id",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = Convert.ToString(currentClient.id)
                    };
                    OracleParameter curs = new OracleParameter
                    {
                        ParameterName = "curs",
                        Direction = ParameterDirection.Output,
                        OracleDbType = OracleDbType.RefCursor
                    };
                    using (OracleCommand command = new OracleCommand("Administrator.getClientData", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] { id, curs });
                        var reader = command.ExecuteReader();
                        DataTable dt = new DataTable();
                        dt.Load(reader);

                        foreach (DataRow row in dt.Rows)
                        {
                            currentClient.phoneNumber = row["PhoneNumber"].ToString();
                            currentClient.balance = double.Parse(row["Balance"].ToString());
                            currentClient.minutes = row["Minutes"].ToString();
                            currentClient.sms = row["SMS"].ToString();
                            currentClient.mms = row["MMS"].ToString();
                            currentClient.megabytes = row["Megabytes"].ToString();
                        }
                    }

                    myPhoneNumber.Content = "Номер: " + currentClient.phoneNumber;
                    myBalance.Content = "Баланс: " + Convert.ToString(currentClient.balance)+" руб.";
                    myMins.Content = "Минуты: " + currentClient.minutes;
                    mySMS.Content = "SMS: " + currentClient.sms;
                    myMMS.Content = "MMS: " + currentClient.mms;
                    myMegabytes.Content = "Мегабайты: " + String.Format("{0:f1}", float.Parse(currentClient.megabytes));


                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
            catch (Exception ex)
            {
                myMegabytes.Content = "Мегабайты: " + currentClient.megabytes;
            }
        }
        private void ClientWindow_Loaded(object sender, RoutedEventArgs e)
        {
           currClientData();
           personalData.Visibility = Visibility.Visible;
           changeTariffSP.Visibility = Visibility.Collapsed;
           balanceReplenishmentSP.Visibility = Visibility.Collapsed;
           moneyTransferSP.Visibility = Visibility.Collapsed;
           internet.Content = "Включить передачу данных";
           callSP.Visibility = Visibility.Collapsed;
        }

        private void homePage_Click(object sender, RoutedEventArgs e)
        {
            currClientData();
            personalData.Visibility = Visibility.Visible;
            changeTariffSP.Visibility = Visibility.Collapsed;
            balanceReplenishmentSP.Visibility = Visibility.Collapsed;
            moneyTransferSP.Visibility = Visibility.Collapsed;

            callSP.Visibility = Visibility.Collapsed;
        }

        private void ChangeTariff()
        {
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.clientConn))
                {
                    connection.Open();

                    OracleParameter id = new OracleParameter
                    {
                        ParameterName = "in_id",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = Convert.ToString(currentClient.id)
                    };
                    OracleParameter tar = new OracleParameter
                    {
                        ParameterName = "in_tariff",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = tariffsText.Text
                    };
                    using (OracleCommand command = new OracleCommand("Administrator.changeTariff", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] { id, tar });
                        command.ExecuteNonQuery();
                        MessageBox.Show("Тариф был изменен успешно");
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void changeTariff_Click(object sender, RoutedEventArgs e)
        {
            tariffsText.Items.Clear();
            changeTariffSP.Visibility =  Visibility.Visible;
            personalData.Visibility = Visibility.Collapsed;
            balanceReplenishmentSP.Visibility = Visibility.Collapsed;
            moneyTransferSP.Visibility = Visibility.Collapsed;
            callSP.Visibility = Visibility.Collapsed;
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.clientConn))
                {
                    connection.Open();
                    OracleParameter tariff = new OracleParameter
                    {
                        ParameterName = "tariff",
                        Direction = ParameterDirection.Output,
                        OracleDbType = OracleDbType.RefCursor
                    };

                    using (OracleCommand command = new OracleCommand("Administrator.getTariffs"))
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] { tariff });
                        var reader = command.ExecuteReader();
                        DataTable dt = new DataTable();
                        dt.Load(reader);

                        foreach (DataRow row in dt.Rows)
                        {
                            tariffsText.Items.Add(row["Name"].ToString());
                        }
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void MoneyTransfer()
        {
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.clientConn))
                {
                    connection.Open();

                    OracleParameter id = new OracleParameter
                    {
                        ParameterName = "in_id",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = Convert.ToString(currentClient.id)
                    };
                    OracleParameter summ = new OracleParameter
                    {
                        ParameterName = "in_summ",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.Decimal,
                        Value = double.Parse(summTransferText.Text)
                    };
                    OracleParameter num = new OracleParameter
                    {
                        ParameterName = "in_phone",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = numTransferText.Text
                    };
                    using (OracleCommand command = new OracleCommand("Administrator.moneyTransfer", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] { id, summ, num});
                        command.ExecuteNonQuery();
                        MessageBox.Show("Операция проведена успешно");
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void changeTariffButton_Click(object sender, RoutedEventArgs e)
        {
            ChangeTariff();
        }

        private void moneyTransfer_Click(object sender, RoutedEventArgs e)
        {
            changeTariffSP.Visibility = Visibility.Collapsed;
            personalData.Visibility = Visibility.Collapsed;
            balanceReplenishmentSP.Visibility = Visibility.Collapsed;
            moneyTransferSP.Visibility = Visibility.Visible;
            callSP.Visibility = Visibility.Collapsed;

        }

        private void balanceReplenishment_Click(object sender, RoutedEventArgs e)
        {
            changeTariffSP.Visibility = Visibility.Collapsed;
            personalData.Visibility = Visibility.Collapsed;
            balanceReplenishmentSP.Visibility = Visibility.Visible;
            moneyTransferSP.Visibility = Visibility.Collapsed;
            callSP.Visibility = Visibility.Collapsed;
        }

        private void replenishButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.clientConn))
                {
                    connection.Open();
                    OracleParameter id = new OracleParameter
                    {
                        ParameterName = "in_id",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = Convert.ToString(currentClient.id)
                    };
                    OracleParameter sum = new OracleParameter
                    {
                        ParameterName = "in_summ",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.Decimal,
                        Value = double.Parse(summReplenishText.Text)
                    };

                    using (OracleCommand command = new OracleCommand("Administrator.balanceReplenishment"))
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] {id,sum });
                        command.ExecuteNonQuery();
                        MessageBox.Show("Пополнение прошло успешно");
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void transferButton_Click(object sender, RoutedEventArgs e)
        {
            MoneyTransfer();
        }

        private void smsSend_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.clientConn))
                {
                    connection.Open();
                    OracleParameter id = new OracleParameter
                    {
                        ParameterName = "in_id",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = Convert.ToString(currentClient.id)
                    };

                    using (OracleCommand command = new OracleCommand("Administrator.sendSMS"))
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] { id});
                        command.ExecuteNonQuery();
                        MessageBox.Show("Операция завершена успешно");
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void mmsSend_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.clientConn))
                {
                    connection.Open();
                    OracleParameter id = new OracleParameter
                    {
                        ParameterName = "in_id",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = Convert.ToString(currentClient.id)
                    };

                    using (OracleCommand command = new OracleCommand("Administrator.sendMMS"))
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] { id });
                        command.ExecuteNonQuery();
                        MessageBox.Show("Операция завершена успешно");
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        async Task TraficCount()
        {
            while (internet.Content== "Выключить передачу данных")
            {
                await Task.Delay(1000);
                tr += performanceCounterReceived.NextValue() / 1000000;
                qqq.Content = "Потрачено mb: "+ String.Format("{0:f1}", tr);
            }
            
        }

        private void debitInternet()
        {
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.clientConn))
                {
                    connection.Open();
                    OracleParameter id = new OracleParameter
                    {
                        ParameterName = "in_id",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = Convert.ToString(currentClient.id)
                    };

                    OracleParameter mb = new OracleParameter
                    {
                        ParameterName = "in_mbcount",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.Decimal,
                        Value = (double)tr
                    };
                    using (OracleCommand command = new OracleCommand("Administrator.useInternet"))
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] { id, mb });
                        command.ExecuteNonQuery();
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void internet_Click_1(object sender, RoutedEventArgs e)
        {
            if (internet.Content == "Включить передачу данных")
            {
                internet.Content = "Выключить передачу данных";
                TraficCount();
            }
            else if (internet.Content == "Выключить передачу данных")
            {
                internet.Content = "Включить передачу данных";
            }
            debitInternet();
            tr = 0;
        }

        private void callButt_Click(object sender, RoutedEventArgs e)
        {
            changeTariffSP.Visibility = Visibility.Collapsed;
            personalData.Visibility = Visibility.Collapsed;
            balanceReplenishmentSP.Visibility = Visibility.Collapsed;
            moneyTransferSP.Visibility = Visibility.Collapsed;
            callSP.Visibility = Visibility.Visible;
        }

        private void Call()
        {
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.clientConn))
                {
                    connection.Open();
                    OracleParameter id = new OracleParameter
                    {
                        ParameterName = "in_id",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = Convert.ToString(currentClient.id)
                    };

                    OracleParameter phone = new OracleParameter
                    {
                        ParameterName = "in_phone",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = interlocNumText.Text
                    };
                    using (OracleCommand command = new OracleCommand("Administrator.startCall"))
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] { id, phone });
                        command.ExecuteNonQuery();
                        MessageBox.Show("Связь установлена");
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void callButton_Click(object sender, RoutedEventArgs e)
        {
            Call();
        }
        private void ThrowCall()
        {
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.clientConn))
                {
                    connection.Open();
                    OracleParameter id = new OracleParameter
                    {
                        ParameterName = "in_id",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = Convert.ToString(currentClient.id)
                    };

                    using (OracleCommand command = new OracleCommand("Administrator.endCall"))
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] { id});
                        command.ExecuteNonQuery();
                        MessageBox.Show("Звонок завершен");
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private void throwCallButton_Click(object sender, RoutedEventArgs e)
        {
            ThrowCall();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            interlocNumText.Text += "1";
        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            interlocNumText.Text += "2";
        }

        private void Button_Click_2(object sender, RoutedEventArgs e)
        {
            interlocNumText.Text += "3";
        }

        private void Button_Click_3(object sender, RoutedEventArgs e)
        {
            interlocNumText.Text += "0";
        }

        private void Button_Click_4(object sender, RoutedEventArgs e)
        {
            interlocNumText.Text += "4";
        }

        private void Button_Click_5(object sender, RoutedEventArgs e)
        {
            interlocNumText.Text += "5";
        }

        private void Button_Click_6(object sender, RoutedEventArgs e)
        {
            interlocNumText.Text += "6";
        }

        private void Button_Click_7(object sender, RoutedEventArgs e)
        {
            interlocNumText.Text += "+";
        }

        private void Button_Click_8(object sender, RoutedEventArgs e)
        {
            interlocNumText.Text += "7";
        }

        private void Button_Click_9(object sender, RoutedEventArgs e)
        {
            interlocNumText.Text += "8";
        }

        private void Button_Click_10(object sender, RoutedEventArgs e)
        {
            interlocNumText.Text += "9";
        }
    }
}
