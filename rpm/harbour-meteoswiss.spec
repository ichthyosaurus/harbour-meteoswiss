# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.32
# 

Name:       harbour-meteoswiss

# >> macros
# << macros
%define __provides_exclude_from ^%{_datadir}/.*$

Summary:    Unofficial client to the Swiss Meteorological Service (MeteoSwiss)
Version:    2.0.0
Release:    1
Group:      Applications/Productivity
License:    GPL-3.0-or-later
URL:        https://github.com/ichthyosaurus/harbour-meteoswiss
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-meteoswiss.yaml
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.3
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
MeteoSwiss is an unofficial client to weather forecast services provided by
the Federal Office of Meteorology and Climatology (MeteoSwiss). Forecasts are
available offline and updated every hour.


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qmake5  \
    VERSION=%{version} \
    RELEASE=%{release}

make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# >> files
# << files
