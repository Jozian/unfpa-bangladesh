import React from "react";
import clsx from "clsx";
import { Nav, selectDrawerOpen } from "components/nav";
import { CssBaseline } from "@material-ui/core";
import { makeStyles } from "@material-ui/styles";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import { selectAuthenticated } from "components/pages/login";
import { Redirect } from "react-router-dom";
import { Notifier } from "components/notifier";
import styles from "./styles.css";

const AppLayout = ({ children, drawerOpen, isAuthenticated }) => {
  const css = makeStyles(styles)();

  if (!isAuthenticated) {
    return <Redirect to="/login" />;
  }

  return (
    <div className={css.root}>
      <CssBaseline />
      <Notifier />
      <Nav />
      <main
        className={clsx(css.content, {
          [css.contentShift]: drawerOpen
        })}
      >
        {children}
      </main>
    </div>
  );
};

AppLayout.propTypes = {
  children: PropTypes.object,
  drawerOpen: PropTypes.bool.isRequired,
  isAuthenticated: PropTypes.bool.isRequired
};

const mapStateToProps = state => ({
  drawerOpen: selectDrawerOpen(state),
  isAuthenticated: selectAuthenticated(state)
});

export default connect(mapStateToProps)(AppLayout);