require 'spec_helper'

describe 'nis' do
  let(:facts) {{:osfamily => 'Debian'}}

  context 'client' do
    let(:params) {{:client => true, :ypdomain => 'MYDOMAIN', :ypserv => ['nis'], :server => false}}
    let(:facts) {{:osfamily => 'Debian'}}
    it {should contain_class('nis::client::install')}
    it {should contain_class('nis::client::config')}
    it {should contain_class('nis::client::service')}
   
    it do 
      should contain_file('/etc/yp.conf').with({
        'ensure' => 'file',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644'
      })
      should contain_file('/etc/yp.conf').with_content(/ypserver nis/)
    end
    context 'on Debian' do
      let(:facts) {{:osfamily => 'Debian'}}
      it {should contain_file('/etc/defaultdomain')}
      it { is_expected.to contain_package('nis') }
      it {is_expected.to contain_service('nis') }
    end
  end

  context 'server' do
    let(:params) {{:server => true, :master => true, :ypdomain => 'MYDOMAIN', :client => false, :ypmaster => 'master', :ypserv => ['nis'], :nicknames => true, :securenets => true }}
    let(:facts) {{:osfamily => 'Debian'}}
    it {should contain_class('nis::server::install')}
    it {should contain_class('nis::server::config')}
    it {should contain_class('nis::server::service')}
    it do
      should contain_exec('yp-config').with(
        :command => 'domainname MYDOMAIN && ypinit -m',
        :path    => ['/bin','/usr/bin','/usr/lib64/yp','/usr/lib/yp','/usr/sbin' ],
        :unless  => 'test -d /var/yp/MYDOMAIN'
      )
    end


    context 'with nicknames => true' do 
      let(:facts) {{:osfamily => 'Debian'}}
      it do
        should contain_file('/var/yp/nicknames').with({
          'ensure' => 'file',
          'owner'  => 'root', 
	  'group'  => 'root',
	  'mode'   => '0644',
        })
      end
    end
        
    context 'with securenets => true' do
        it do
          should contain_file('/var/yp/securenets').with({
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644'
          })
        end
    end

    context 'on Debian' do
      let(:facts) {{:osfamily => 'Debian'}}
      it { should contain_file('/etc/defaultdomain')}
      it { is_expected.to contain_package('nis') }
      it { is_expected.to contain_service('nis') }
      it { should contain_file('/etc/yp.conf').with_content(/domain MYDOMAIN server nis/) }
    end
    context 'on RedHat' do
      let(:facts) {{:osfamily => 'RedHat'}}
      it { is_expected.to contain_package('ypserv') }
      it {is_expected.to contain_service('ypserv') }
    end

  end

end
